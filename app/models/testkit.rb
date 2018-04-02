class Testkit < ActiveRecord::Base
  belongs_to :author, :class_name => 'User'
  belongs_to :assigned_to, :class_name => 'Principal'
  belongs_to :project
  belongs_to :user_start, :class_name => 'Principal'
  belongs_to :user_end, :class_name => 'Principal'
  belongs_to :parent, :class_name => 'Testkit'
  has_and_belongs_to_many :testcases, -> { order(:id) }, :autosave => true
  has_and_belongs_to_many :issues
  has_and_belongs_to_many :versions

  accepts_nested_attributes_for :testcases

  validates :name, :project_id, :author_id, presence: true
  validates :assigned_to_id, :client_env, :env, presence: true, if: :run

  scope :run, -> { where(run: true, done: false) }
  scope :report, -> { where(run: true, done: true) }

  def report_result
    Testkit.where(id: self.id).joins(:testcases).group(:status).count
  end

  def template_statistics
    Testkit.where(done: true, parent: self).joins(:testcases).group(:status).count
  end

  def templates_done
    Testkit.where(done: true, parent: self).count
  end

  def check_done?
    testcases.pluck(:status).all? {|status| status != ''}
  end

  def have_runs?
    Testkit.where(parent: self).present?
  end

  def template?
    done == false && run == false
  end

  def set_not_run_to_testcases
    testcases.each do |testcase|
      unless testcase.status.present?
        testcase.status = "not_run" 
        testcase.save
      end
    end
  end

  def chart_values
    values = testcases.order_as_specified(status: Testcase.status_list).pluck(:status)
    counts = {pass: 0, fail: 0, blocked: 0, not_run: 0}
    values.each { |status| counts[status.to_sym] += 1 }
    counts.values
  end

  def make_new_run(params)
    Testkit.new(self.dup.attributes.merge(params.merge(:run => true, :parent_id => self.id, :author_id => User.current.id)))
  end

  def copy_testcases
    parent.testcases.each do |testcase|
      new_testcase = testcase.dup
        testcase.steps.each do |step|
          new_testcase.steps << step.dup
        end
      new_testcase.run = true
      new_testcase.parent = testcase
      new_testcase.attachments = testcase.attachments.map do |attachement|
        attachement.copy(:container => new_testcase)
      end
      new_testcase.save!
      self.testcases << new_testcase
    end
  end

  def tree
    out = []
    TestcaseFolder.where(parent_id: nil, project: project).each do |folder|
      out << folder.make_tree(:testkit => self)
    end
    out
  end

  def assignable_users
    users = []
    principals = project.principals.active.uniq
    principals.each do |principal|
      if principal.allowed_to? :pass_runs, project
        users << principal
      end
    end
    users << author
    users << assigned_to if assigned_to
    users.uniq.sort
  end
end
