ActiveAdmin.register Color do
  permit_params :name

  filter :name
end
