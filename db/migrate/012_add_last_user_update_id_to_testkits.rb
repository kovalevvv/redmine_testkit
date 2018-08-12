class AddLastUserUpdateIdToTestkits < ActiveRecord::Migration
  def change
    add_column :testkits, :last_user_update_id, :integer
  end
end
