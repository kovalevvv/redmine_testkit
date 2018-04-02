class CreateTestcases < ActiveRecord::Migration
  def change
    create_table :testcases do |t|
      t.string :name, null: false
      t.text :description
      t.string :status, :default => "", null: false
      t.boolean :active, :default => true, null: false, index: true
      t.boolean :run, :default => false, null: false
      t.integer :author_id, :default => 0, null: false, index: true
      t.integer :folder_id, null: false, index: true, foreign_key: true
      t.integer :parent_id, index: true
      t.integer :project_id, null: false, index: true
      t.timestamps null: false
    end
  end
end
