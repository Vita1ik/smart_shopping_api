class RemoveSlugFromTables < ActiveRecord::Migration[7.2]
  def change
    remove_column :brands, :slug, :string
    remove_column :sizes, :slug, :string
    remove_column :colors, :slug, :string
    remove_column :categories, :slug, :string
    remove_column :target_audiences, :slug, :string
  end
end
