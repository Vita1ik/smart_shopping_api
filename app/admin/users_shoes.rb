ActiveAdmin.register UserShoe do
  # Eager load associations to avoid N+1 queries
  includes :user, :shoe

  permit_params :user_id, :shoe_id, :current_price, :prev_price,
                :discounted, :liked, :visited_discounted_from_email

  index do
    selectable_column
    id_column
    column :user
    column :shoe
    column :current_price
    column :prev_price
    column :discounted
    column :liked
    column :visited_discounted_from_email
    column :created_at
    actions
  end

  filter :user
  filter :shoe
  filter :liked
  filter :discounted
  filter :current_price
  filter :created_at

  form do |f|
    f.inputs do
      f.input :user
      f.input :shoe
      f.input :current_price
      f.input :prev_price
      f.input :discounted
      f.input :liked
      f.input :visited_discounted_from_email
    end
    f.actions
  end
end