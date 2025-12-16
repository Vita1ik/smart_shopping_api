class AddNewFieldsToUsersShoes < ActiveRecord::Migration[7.2]
  def change
    add_column :users_shoes, :discounted, :boolean
    add_column :users_shoes, :current_price, :integer
    add_column :users_shoes, :prev_price, :integer
  end
end
