class CreateIssuesTestkits < ActiveRecord::Migration
  def change
    create_table :issues_testkits do |t|
      t.belongs_to :issue, index: true, foreign_key: true
      t.belongs_to :testkit, index: true, foreign_key: true
    end
  end
end
