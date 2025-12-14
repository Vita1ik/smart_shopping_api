ActiveAdmin.register Source do
  permit_params :name

  filter :name
end
