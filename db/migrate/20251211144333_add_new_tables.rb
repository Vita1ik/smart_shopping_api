class AddNewTables < ActiveRecord::Migration[7.2]
  def change
    create_table :sizes do |t|
      t.string :name, null: false
      t.string :slug, null: false
    end
    add_index :sizes, :slug, unique: true

    create_table :brands do |t|
      t.string :name, null: false
      t.string :slug, null: false
    end
    add_index :brands, :slug, unique: true

    create_table :colors do |t|
      t.string :name, null: false
      t.string :slug, null: false
    end
    add_index :colors, :slug, unique: true

    create_table :target_audiences do |t|
      t.string :name, null: false
      t.string :slug, null: false
    end
    add_index :target_audiences, :slug, unique: true

    create_table :categories do |t|
      t.string :name, null: false
      t.string :slug, null: false
    end
    add_index :categories, :slug, unique: true

    create_table :sources do |t|
      t.string :name, null: false
      t.string :integration_type, null: false
      t.timestamps
    end

    create_table :shoes do |t|
      t.string :name, null: false
      t.jsonb :images, null: false, default: []
      t.bigint :price, null: false
      t.jsonb :prev_prices
      t.text :product_url, null: false

      t.references :brand, null: false, foreign_key: true
      t.references :size, null: false, foreign_key: true
      t.references :color, null: false, foreign_key: true
      t.references :target_audience, null: false, foreign_key: { to_table: :target_audiences }
      t.references :source, null: false, foreign_key: true

      t.timestamps
    end

    create_table :searches do |t|
      t.references :user, null: false, foreign_key: true
      t.jsonb :price_range
      t.timestamps
    end

    create_table :users_shoes do |t|
      t.references :user, null: false, foreign_key: true
      t.references :shoe, null: false, foreign_key: true
      t.boolean :liked, null: false, default: false
      t.timestamps
    end
    add_index :users_shoes, [:user_id, :shoe_id], unique: true

    create_join_table :searches, :sizes do |t|
      t.index [:search_id, :size_id], unique: true
    end

    create_join_table :searches, :colors do |t|
      t.index [:search_id, :color_id], unique: true
    end

    create_table :searches_target_audiences, id: false do |t|
      t.references :search, null: false, foreign_key: true
      t.references :target_audience, null: false, foreign_key: true
    end
    add_index :searches_target_audiences, [:search_id, :target_audience_id], unique: true, name: 'idx_searches_ta_unique'

    create_join_table :searches, :brands do |t|
      t.index [:search_id, :brand_id], unique: true
    end

    create_join_table :searches, :categories do |t|
      t.index [:search_id, :category_id], unique: true
    end

    create_join_table :sources, :categories do |t|
      t.index [:source_id, :category_id], unique: true
    end

    add_column :users, :avatar, :string
    add_reference :users, :size, null: true, foreign_key: true
    add_reference :users, :target_audience, null: true, foreign_key: { to_table: :target_audiences }
    change_column_null :users, :first_name, false
  end
end
