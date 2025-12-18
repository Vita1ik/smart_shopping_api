ActiveAdmin.register Color do
  menu parent: 'Filters', priority: 2
  permit_params :name

  filter :name
end
