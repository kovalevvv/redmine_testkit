class AddFieldProductionToTestcase < ActiveRecord::Migration
  def change
    add_column :testcases, :run_in_production, :boolean
  end
end
