class AddShoeToUserPhotos < ActiveRecord::Migration[7.2]
  def change
    add_reference :user_photos, :shoe, null: true, foreign_key: true
  end
end
