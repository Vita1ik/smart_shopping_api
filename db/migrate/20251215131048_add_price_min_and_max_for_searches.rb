class AddPriceMinAndMaxForSearches < ActiveRecord::Migration[7.2]
  def change
    add_column :searches, :price_min, :integer
    add_column :searches, :price_max, :integer
  end
end
