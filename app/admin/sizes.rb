ActiveAdmin.register Size do
  permit_params :name

  filter :name
end
