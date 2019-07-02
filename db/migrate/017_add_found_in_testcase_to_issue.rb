class AddFoundInTestcaseToIssue < ActiveRecord::Migration
  def change
    add_column :issues, :found_in_testcase_id, :integer
  end
end
