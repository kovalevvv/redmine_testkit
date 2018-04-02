class CreateTestkitsVersions < ActiveRecord::Migration
  def change
    create_table :testkits_versions do |t|
      t.belongs_to :testkit, index: true, foreign_key: true
      t.belongs_to :version, index: true, foreign_key: true
    end
  end
end
