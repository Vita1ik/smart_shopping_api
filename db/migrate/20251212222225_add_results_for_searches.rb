class AddResultsForSearches < ActiveRecord::Migration[7.2]
  def change
    add_column :searches, :results, :jsonb
  end
end
