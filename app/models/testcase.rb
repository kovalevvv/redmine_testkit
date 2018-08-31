class Testcase < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  belongs_to :folder, :class_name => 'TestcaseFolder', foreign_key: "folder_id"

  has_many :steps, -> { order(:id) }, class_name: "TestcaseStep", dependent: :destroy
  accepts_nested_attributes_for :steps, allow_destroy: true

  has_and_belongs_to_many :testkits
  belongs_to :project
  belongs_to :parent, :class_name => 'Testcase'

  acts_as_attachable
  acts_as_taggable
  
  extend OrderAsSpecified
  
  scope :run, -> { where(run: true) }
  scope :not_run, -> { where(run: false) }

  validates :folder_id, :name, :description, presence: true, unless: :run

  TESTCASE_STATUSES = %w(pass fail blocked not_run)
  TESTCASE_PRIORITIES = %w(low normal critical)

  include ActionView::Helpers::DateHelper

  def duration_text
    distance_of_time_in_words(0, duration.minutes)
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

  def to_tree(testkit: nil)
    title = tag_list.present? ? "[##{id}] #{name} (#{tag_list.join(", ")})" : "[##{id}] #{name}"
    r = {title: title, key: id, type: "Testcase", icon: priority}
    if testkit and testkit.testcases.include?(self)
      r.merge!(:selected => true)
    end
    unless run_in_production
      r.merge!(:extraClasses => 'critical')
    end
    r
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
