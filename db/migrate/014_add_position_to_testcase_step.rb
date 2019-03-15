class AddPositionToTestcaseStep < ActiveRecord::Migration
  def change
    add_column :testcase_steps, :position, :integer
    Testcase.all.each {|t| t.steps.order(:id).each.with_index(1) {|s,i| s.update_column :position, i }}
  end
end
