class AddPrefixToTestkitSettings < ActiveRecord::Migration
  def change
    add_column :testkit_settings, :testcase_prefix, :string
  end
end
