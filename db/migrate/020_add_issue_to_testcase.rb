class AddIssueToTestcase < ActiveRecord::Migration
  def change
    add_reference :testcases, :issue, index: true, foreign_key: true
  end
end
