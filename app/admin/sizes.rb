ActiveAdmin.register Size do
  menu parent: 'Filters', priority: 3
  permit_params :name

  filter :name
end
