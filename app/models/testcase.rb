class TestcaseValidator < ActiveModel::Validator
  def validate(record)
    testkit = Testkit.new(author: User.current, created_at: Time.now, parent: Testkit.new(name: "test"), assigned_to: User.current)
    begin
      template = Sablon.template(File.expand_path(TestkitSetting::default_template(:test_plan)))
    rescue StandardError => e
      record.errors[:base] << "%s: %s" % [I18n.t(:word_converter_error), e.message]
    end

    context = {
          project: 'test',
          report: testkit.as_json
        }.merge!(:testcases => [record.as_json({:include => {:steps => {:methods => [:if_doc, :then_doc], :except => [:if, :then]}}, :methods => [:duration_text, :description_doc, :name_with_id]})])

    begin
      template.render_to_string(context)
    rescue StandardError => e
      record.errors[:base] << "%s: %s" % [I18n.t(:word_converter_error), e.message]
    end
  end

end

class Testcase < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  belongs_to :folder, :class_name => 'TestcaseFolder', foreign_key: "folder_id"
  belongs_to :issue

  has_many :steps, -> { order(:position) }, class_name: "TestcaseStep", dependent: :destroy
  accepts_nested_attributes_for :steps, allow_destroy: true

  has_and_belongs_to_many :testkits
  belongs_to :project
  belongs_to :parent, :class_name => 'Testcase'
  has_many :defects, :class_name => 'Issue', foreign_key: 'found_in_testcase_id'

  acts_as_attachable
  acts_as_taggable
  
  extend OrderAsSpecified
  
  scope :run, -> { where(run: true) }
  scope :not_run, -> { where(run: false) }

  validates :folder_id, :name, :description, presence: true, unless: :run
  validates_with TestcaseValidator
  validates_uniqueness_of :issue_id, :allow_blank => true, :allow_nil => true, scope: :run, unless: :run, message: :attached_to_another_task
  validate :ensure_issue_exists, unless: :run

  TESTCASE_STATUSES = %w(pass fail blocked not_run)
  TESTCASE_PRIORITIES = %w(low normal critical)

  include ActionView::Helpers::DateHelper
  include AttachmentPatch if defined?(AttachmentPatch) == 'constant' && AttachmentPatch.class == Module  

  def ensure_issue_exists
    if self.issue_id.present?
      errors.add(:issue) unless Issue.find_by_id(self.issue_id)
    end
  end

  def duration_text
    distance_of_time_in_words(0, duration.minutes)
  end

  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ApplicationHelper

  def clear_text(textile)
    n = Nokogiri::XML.fragment(textilizable(textile, :headings => false))
    n.css('img').remove
    n.css('abbr').each {|node| node.replace "#{n.text}(#{n.attribute('title')})"}
    n.css('ins').each do |node|
      new_node = Nokogiri::XML::Node.new('u', n)
      new_node.content = node.text
      node.replace new_node
    end
    n.css('a.wiki-anchor').remove
    n.css('a').each do |node|
      unless node[:href] =~ /^http/i
        node[:href] = 'https://repo.mos.ru' + node[:href]
      end
      node[:style] = 'color: #5B9BD5; text-decoration: underline'
      node.remove if node.has_attribute?('name')
    end
    n.css('blockquote').reverse.each {|node| node.replace node.inner_html }
    n.css('pre').each {|node| node.replace node.inner_html }
    n.to_html
  end

  def as_json(options = {})
    json = super(options)
    json.merge!({
      'issue_name' => issue.to_s,
      'issue_status' => issue.status.name,
      'issue_priority' => issue.priority.name
    }) if issue
    json
  end

  def description_doc
    Sablon.content(:html, clear_text(self.description))
  end

  def chart_values
    values = steps.order_as_specified(status: Testcase.status_list).pluck(:status)
    counts = {pass: 0, fail: 0, blocked: 0, not_run: 0}
    values.each { |status| counts[status.to_sym] += 1 }
    counts.values
  end

  def run_count
    Testcase.joins(:testkits).where("testkits.done = ?", true).where(parent: self).count
  end

  def statistics
    Testcase.joins(:testkits).where("testkits.done = ?", true).where(parent: self).group(:status).count
  end

  def attachments_editable?(user=User.current)
    run ? false : true
  end

  def attachments_visible?(user=User.current)
    true
  end

  def attachments_deletable?(user=User.current)
    run ? false : true
  end

  def self.status_list
    TESTCASE_STATUSES
  end

  def self.priorities_list
    TESTCASE_PRIORITIES
  end

  def current_id
    prefix = "#{project.testkit_setting && project.testkit_setting.testcase_prefix.present? ? project.testkit_setting.testcase_prefix : "TC"}"
    parent ? "#{prefix}#{parent.id}" : "#{prefix}#{id}"
  end

  def name_with_id(link: false)
    title = link ? link_to(name.mb_chars.humanize, project_testcase_path(:project_id => project.identifier, :id => self.id), remote: true) : name.mb_chars.humanize
    "[#{current_id}] #{title}"
  end

  def to_tree(testkit: nil)
    title = tag_list.present? ? "#{name_with_id} (#{tag_list.join(", ")})" : "#{name_with_id}"
    node = {
      title: title,
      key: id,
      type: "Testcase",
      icon: priority,
      path: Rails.application.routes.url_helpers.project_testcase_path(project_id: self.project.identifier, id: self.id),
      selected_link: tag_list.present? ? "#{name_with_id(link: true)} (#{tag_list.join(", ")})" : "#{name_with_id(link: true)}"
    }
    node.merge!(:selected => true) if testkit and testkit.testcases.include?(self)
    node.merge!(:extraClasses => 'critical') unless run_in_production
    node.merge!(:issue => issue.id) if issue
    node
  end

  def self.available_tags(options = {})
    scope_testcases = Testcase.select('testcases.id')
    scope_testcases = scope_testcases.where(:project => options[:project]) if options[:project]
    result_scope = ActsAsTaggableOn::Tag
      .joins(:taggings)
      .select('tags.id, tags.name, tags.taggings_count, COUNT(taggings.id) as count')
      .group('tags.id, tags.name, tags.taggings_count')
      .where(taggings: { taggable_type: 'Testcase', taggable_id: scope_testcases})

      if options[:name_like]
        matcher = "%#{options[:name_like].downcase}%"

        case connection.adapter_name
        when 'PostgreSQL'
          result_scope = result_scope.where('tags.name ILIKE ?', matcher)
        else
          result_scope = result_scope.where('tags.name LIKE ?', matcher)
        end
      end
    result_scope
  end

end
