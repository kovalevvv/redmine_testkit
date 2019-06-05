class AddInfoToTestcaseStep < ActiveRecord::Migration
  def change
    add_column :testcase_steps, :info, :string
  end
end
