class AddDisplayedNameForTargetAudiences < ActiveRecord::Migration[7.2]
  def change
    add_column :target_audiences, :display_name, :string
  end
end
