class CreateTestkitEnvs < ActiveRecord::Migration
  def change
    create_table :testkit_envs do |t|
      t.string :name, null: false
      t.integer :project_id, null: false, index: true
      t.string :env_type, :limit => 30, :default => "", :null => false
      t.timestamps null: false
    end
    add_index :testkit_envs, [:project_id, :env_type]
  end
end
