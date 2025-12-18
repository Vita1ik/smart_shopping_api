class AddToUsersShoesVisitedDiscountedFromEmail < ActiveRecord::Migration[7.2]
  def change
    add_column :users_shoes, :visited_discounted_from_email, :boolean
  end
end
