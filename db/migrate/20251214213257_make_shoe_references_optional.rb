class MakeShoeReferencesOptional < ActiveRecord::Migration[7.2]
  def change
    change_column_null :shoes, :brand_id, true
    change_column_null :shoes, :category_id, true
    change_column_null :shoes, :color_id, true
    change_column_null :shoes, :size_id, true
    change_column_null :shoes, :target_audience_id, true
    change_column_null :shoes, :source_id, true
  end
end
