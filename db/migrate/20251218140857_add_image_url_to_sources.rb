class AddImageUrlToSources < ActiveRecord::Migration[7.2]
  def change
    add_column :sources, :image_url, :string
  end
end
