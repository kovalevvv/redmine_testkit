class AddPriorityToTestcase < ActiveRecord::Migration
  def change
    add_column :testcases, :priority, :string, :default => 'normal'
  end
end
