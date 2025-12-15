ActiveAdmin.register Source do
  permit_params :name, :integration_type

  filter :name
end
