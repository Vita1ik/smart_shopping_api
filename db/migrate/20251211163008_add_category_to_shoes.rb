class AddCategoryToShoes < ActiveRecord::Migration[7.2]
  def change
    add_reference :shoes, :category, null: false, foreign_key: true
  end
end
