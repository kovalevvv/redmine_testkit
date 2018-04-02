class CreateTestkits < ActiveRecord::Migration
  def change
    create_table :testkits do |t|
      t.string :name, null: false
      t.text :description
      t.boolean :active, :default => true, null: false
      t.boolean :run, :default => false, null: false
      t.boolean :done, :default => false, null: false
      t.text :comment
      t.integer :author_id, :default => 0, null: false
      t.integer :assigned_to_id, :default => 0, null: false
      t.integer :project_id, null: false, index: true
      t.string :env
      t.string :client_env
      t.integer :user_start_id
      t.integer :user_end_id
      t.integer :parent_id, foreign_key: true, index: true
      t.datetime :start_date
      t.datetime :done_date
      t.timestamps null: false
    end
  end
end
