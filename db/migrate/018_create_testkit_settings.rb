class CreateTestkitSettings < ActiveRecord::Migration
  def change
    create_table :testkit_settings do |t|
      t.belongs_to :project, index: true, foreign_key: true
      t.integer :new_defect_tracker_id
    end
  end
end
