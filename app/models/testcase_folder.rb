class TestcaseFolder < ActiveRecord::Base
  has_many :children, class_name: "TestcaseFolder", foreign_key: "parent_id"
  belongs_to :parent, class_name: "TestcaseFolder"
  has_many :testcases, foreign_key: "folder_id"
  belongs_to :project
  validates :name, :presence => true

  def make_tree(folder=self, testkit: nil, tags: nil)
    children = []
    children << folder.children.collect { |folder| make_tree(folder, testkit: testkit, tags: tags) } if folder.children.present?
    if tags
      children << folder.testcases.not_run.tagged_with(tags).order(:created_at).collect { |t| t.to_tree :testkit => testkit } if folder.testcases.not_run.present?
    else
      children << folder.testcases.not_run.order(:created_at).collect { |t| t.to_tree :testkit => testkit } if folder.testcases.not_run.present?
    end
    out = {title: "[##{folder.id}] #{folder.name} (#{I18n.t :testcase, count: folder.testcases.not_run.count})", key: folder.id, type: "TestcaseFolder", folder: true}
    if children
      out.merge!({expanded: true, children: children.flatten})
    end
    [out]
  end

  def text_method
    "[##{id}] #{name}"
  end
end
