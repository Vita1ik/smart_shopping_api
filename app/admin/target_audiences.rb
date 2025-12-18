ActiveAdmin.register TargetAudience do
  menu parent: 'Filters', priority: 4
  permit_params :name

  filter :name
end
