class AddDeviseToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :encrypted_password, :string, null: false, default: ""
    remove_column :users, :password_digest
  end
end
