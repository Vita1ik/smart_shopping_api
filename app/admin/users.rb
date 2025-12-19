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
  # --- SHOW PAGE ---
  show do
    # 1. Основна інформація
    panel "User Profile" do
      attributes_table_for user do
        row :avatar do |u|
          if u.avatar.present?
            image_tag(u.avatar, style: "width: 100px; border-radius: 8px; object-fit: cover;")
          end
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

    # 2. Блок фотографій (Virtual Try-On)
    # Ми розділяємо їх на дві колонки: завантажені юзером та згенеровані AI
    columns do
      # Колонка А: Оригінальні фото користувача
      column span: 1 do
        panel "Uploaded Photos (Sources)" do
          # Вибираємо фото, де НЕМАЄ shoe_id
          source_photos = user.user_photos.where(shoe_id: nil).with_attached_image

          if source_photos.any?
            div style: "display: grid; grid-template-columns: repeat(auto-fill, minmax(120px, 1fr)); gap: 15px;" do
              source_photos.each do |photo|
                div style: "text-align: center;" do
                  if photo.image.attached?
                    # Відображаємо картинку
                    span link_to image_tag(photo.image, style: "width: 100%; height: 150px; object-fit: cover; border-radius: 8px; border: 1px solid #ddd;"), photo.image.url, target: "_blank"
                  end
                end
              end
            end
          else
            div "No uploaded photos.", style: "color: #888; padding: 20px; text-align: center;"
          end
        end
      end

      # Колонка Б: Результати примірки
      column span: 2 do # Робимо цю колонку ширшою
        panel "Virtual Try-On History (Generated)" do
          # Вибираємо фото, де Є shoe_id, і підвантажуємо взуття для швидкості
          generated_photos = user.user_photos.where.not(shoe_id: nil).includes(:shoe).with_attached_image.order(created_at: :desc)

          if generated_photos.any?
            div style: "display: grid; grid-template-columns: repeat(auto-fill, minmax(150px, 1fr)); gap: 15px;" do
              generated_photos.each do |photo|
                div style: "border: 1px solid #eee; border-radius: 8px; overflow: hidden; background: #fff;" do
                  # Картинка-результат
                  if photo.image.attached?
                    img(src: photo.image.url, style: "width: 100%; height: 200px; object-fit: cover;")
                  end

                  # Інформація про взуття
                  div style: "padding: 10px; font-size: 12px; border-top: 1px solid #eee;" do
                    if photo.shoe
                      div style: "font-weight: bold; margin-bottom: 4px;" do
                        link_to photo.shoe.name, admin_shoe_path(photo.shoe)
                      end
                      div number_to_currency(photo.shoe.price, unit: "₴", precision: 0), style: "color: #666;"
                    else
                      span "Shoe deleted", style: "color: red;"
                    end
                    div style: "color: #999; font-size: 10px; margin-top: 5px;" do
                      l(photo.created_at, format: :short)
                    end
                  end
                end
              end
            end
          else
            div "No generated images yet.", style: "color: #888; padding: 20px; text-align: center;"
          end
        end
      end
    end

    # 3. Нижній блок (Лайки та Пошук)
    columns do
      # Ліва колонка - Лайкнуте взуття
      column span: 1 do
        panel "Liked Shoes (#{user.liked_shoes.count})" do
          if user.liked_shoes.any?
            div style: "display: grid; grid-template-columns: repeat(auto-fill, minmax(100px, 1fr)); gap: 10px; max-height: 400px; overflow-y: auto; padding: 10px;" do
              user.liked_shoes.includes(:brand).each do |shoe|
                div style: "border: 1px solid #eee; border-radius: 6px; overflow: hidden; text-align: center;" do
                  img src: shoe.images.first, style: "width: 100px; height: 100px; object-fit: cover;"

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
            column "Date" do |s|
              l(s.created_at, format: :short)
            end
            column "Query/Filters" do |s|
              # Приклад виводу деталей пошуку, якщо вони є
              s.try(:query) || "Filter search"
            end
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