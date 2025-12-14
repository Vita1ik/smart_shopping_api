ActiveAdmin.register TargetAudience do
  permit_params :name

  filter :name
end
