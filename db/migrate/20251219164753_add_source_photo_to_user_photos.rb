class AddSourcePhotoToUserPhotos < ActiveRecord::Migration[7.1]
  def change
    add_reference :user_photos, :source_photo, foreign_key: { to_table: :user_photos }, null: true
  end
end
