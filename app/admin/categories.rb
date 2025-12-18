ActiveAdmin.register Category do
  menu parent: 'Filters', priority: 1
  permit_params :name

  filter :name
end
