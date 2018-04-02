class CreateTestcaseFolders < ActiveRecord::Migration
  def change
    create_table :testcase_folders do |t|
      t.string :name, null: false
      t.integer :parent_id, index: true
      t.integer :project_id, null: false, index: true
      t.timestamps null: false
    end
  end
end
