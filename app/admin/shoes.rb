ActiveAdmin.register Shoe do
  permit_params :name, :price

  filter :name
  filter :by_source_name, as: :searchable_select, multiple: true, label: 'Source name',
         collection: -> { Source.pluck(:name) }
end
