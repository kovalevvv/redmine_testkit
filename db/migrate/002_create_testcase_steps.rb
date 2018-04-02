class CreateTestcaseSteps < ActiveRecord::Migration
  def change
    create_table :testcase_steps do |t|
      t.string :if
      t.string :then
      t.string :result
      t.string :status, :default => "not_run", null: false
      t.integer :testcase_id, null: false, foreign_key: true, index: true
      t.timestamps null: false
    end
  end
end
