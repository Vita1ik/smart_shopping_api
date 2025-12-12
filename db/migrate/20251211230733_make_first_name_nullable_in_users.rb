class MakeFirstNameNullableInUsers < ActiveRecord::Migration[7.2]
  def change
    change_column_null :users, :first_name, true
  end
end
