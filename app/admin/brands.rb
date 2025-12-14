ActiveAdmin.register Brand do
  permit_params :name

  filter :name
end
