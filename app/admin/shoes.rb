ActiveAdmin.register Shoe do
  filter :name

  filter :by_source_name, as: :searchable_select, multiple: true, label: 'Source name',
         collection: -> { Source.pluck(:name) }
end
