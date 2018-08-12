class AddLastUserUpdateDateToTestkits < ActiveRecord::Migration
  def change
    add_column :testkits, :last_user_update_date, :timestamp
  end
end
