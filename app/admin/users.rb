ActiveAdmin.register User do
  includes :size, :target_audience

  permit_params :email, :password, :password_confirmation, :first_name, :last_name,
                :avatar, :size_id, :target_audience_id

  ActiveAdmin.register User do
    index as: :grid, columns: 8 do |user|
      div class: "aa-user-card" do
        div class: "aa-user-avatar-wrapper" do
          if user.avatar.present?
            img src: user.avatar, class: "aa-user-img"
          else
            div class: "aa-user-initials" do
              span user.email.first.upcase
            end
          end
        end

        div class: "aa-user-info" do
          link_to truncate(user.first_name, length: 15), admin_user_path(user), class: "aa-user-email"
        end

        link_to "Show", admin_user_path(user), class: "aa-user-view-btn"
      end
    end
  end

  filter :email

  # --- FILTERS ---
  filter :email
  filter :first_name
  filter :last_name
  filter :size
  filter :target_audience
  filter :created_at

  # --- FORM (EDIT/NEW) ---
  form do |f|
    f.inputs "Account Details" do
      f.input :email
      f.input :first_name
      f.input :last_name
      f.input :avatar, hint: "URL to image"
    end

    f.inputs "Preferences" do
      f.input :size
      f.input :target_audience
    end

    f.inputs "Security" do
      f.input :password
      f.input :password_confirmation
      if f.object.new_record?
        para "Password is required for new users.", class: "inline-hints"
      else
        para "Leave blank if you don't want to change the password.", class: "inline-hints"
      end
    end
    f.actions
  end

  # --- SHOW PAGE ---
  show do
    # Верхня частина - інформація про юзера
    panel "User Profile" do
      attributes_table_for user do
        row :avatar do |u|
          image_tag(u.avatar, style: "width: 100px; border-radius: 8px;") if u.avatar.present?
        end
        row :email
        row :full_name do |u|
          "#{u.first_name} #{u.last_name}"
        end
        row :google_uid
        row :size
        row :target_audience
        row :created_at
        row :sign_in_count if user.respond_to?(:sign_in_count)
      end
    end

    columns do
      # Ліва колонка - Лайкнуте взуття (Gallery)
      column span: 1 do
        panel "Liked Shoes (#{user.liked_shoes.count})" do
          if user.liked_shoes.any?
            div style: "display: grid; grid-template-columns: repeat(auto-fill, minmax(100px, 1fr)); gap: 10px; max-height: 400px; overflow-y: auto; padding: 10px;" do
              user.liked_shoes.includes(:brand).each do |shoe|
                div style: "border: 1px solid #eee; border-radius: 6px; overflow: hidden; text-align: center;" do
                  if shoe.images&.first
                    img src: shoe.images.first, style: "width: 100px; border-radius: 8px;"
                  else
                    div "No Img", style: "height: 80px; line-height: 80px; background: #f9f9f9; color: #ccc;"
                  end
                  div style: "padding: 5px; font-size: 11px;" do
                    div link_to shoe.name, admin_shoe_path(shoe)
                    div shoe.brand&.name, style: "color: #888; text-transform: uppercase; font-size: 9px;"
                    div number_to_currency(shoe.price, unit: "₴", precision: 0), style: "font-weight: bold;"
                  end
                end
              end
            end
          else
            div "User hasn't liked any shoes yet.", style: "padding: 20px; color: #888; text-align: center;"
          end
        end
      end

      # Права колонка - Останні пошуки
      column span: 1 do
        panel "Recent Searches (#{user.searches.count})" do
          table_for user.searches.order(created_at: :desc).limit(10) do
            column "id", :id
            column "Date", :created_at
            column "Actions" do |s|
              link_to "View", admin_search_path(s)
            end
          end
        end
      end
    end
  end

  # --- CONTROLLER LOGIC (Devise Fix) ---
  controller do
    # Цей метод дозволяє оновлювати юзера без введення пароля,
    # якщо поля пароля залишені пустими.
    def update
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete("password")
        params[:user].delete("password_confirmation")
      end
      super
    end
  end
end