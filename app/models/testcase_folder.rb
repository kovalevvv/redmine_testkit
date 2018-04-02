class TestcaseFolder < ActiveRecord::Base
  has_many :children, class_name: "TestcaseFolder", foreign_key: "parent_id"
  belongs_to :parent, class_name: "TestcaseFolder"
  has_many :testcases, foreign_key: "folder_id"
  belongs_to :project
  validates :name, :presence => true

  def make_tree(folder=self, testkit: nil)
    children = []
    children << folder.children.collect { |folder| make_tree(folder, testkit: testkit) } if folder.children.present?
    children << folder.testcases.not_run.collect { |t| t.to_tree :testkit => testkit } if folder.testcases.not_run.present?
    if children
      [{title: folder.name, key: folder.id, type: "TestcaseFolder", folder: true, expanded: true, children: children.flatten}]
    else
      [{title: folder.name, key: folder.id, type: "TestcaseFolder", folder: true}]
    end
  end
end
