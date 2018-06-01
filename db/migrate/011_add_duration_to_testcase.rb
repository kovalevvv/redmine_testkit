class AddDurationToTestcase < ActiveRecord::Migration
  def change
    add_column :testcases, :duration, :integer, :default => 0
  end
end
