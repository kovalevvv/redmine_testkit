class CreateTestcasesTestkits < ActiveRecord::Migration
  def change
    create_table :testcases_testkits do |t|
      t.belongs_to :testcase, index: true, foreign_key: true
      t.belongs_to :testkit, index: true, foreign_key: true
    end
  end
end
