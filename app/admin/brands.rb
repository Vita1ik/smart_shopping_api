ActiveAdmin.register Brand do
  menu parent: 'Filters', priority: 0
  permit_params :name

  filter :name
end
