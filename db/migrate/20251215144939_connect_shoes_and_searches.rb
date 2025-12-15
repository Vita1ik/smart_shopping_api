class ConnectShoesAndSearches < ActiveRecord::Migration[7.2]
  def change
    create_join_table :searches, :shoes do |t|
      t.index [:search_id, :shoe_id], unique: true
    end
  end
end
