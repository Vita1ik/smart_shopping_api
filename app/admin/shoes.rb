ActiveAdmin.register Shoe do
  includes(:brand)

  permit_params :name, :price

  filter :name
  filter :by_source_name, as: :searchable_select, multiple: true, label: 'Source name',
         collection: -> { Source.pluck(:name) }

  index as: :grid, columns: 5 do |shoe|
    div class: "aa-grid-item" do
      div class: "aa-shoe-card" do

        div class: "aa-shoe-header" do
          # Посилання на всю площу хедера
          link_to admin_shoe_path(shoe), class: "aa-shoe-link-overlay" do; end

          div number_to_currency(shoe.price / 100.0, unit: "₴", precision: 0), class: "aa-shoe-price-badge"

          image_url = shoe.images&.first
          if image_url.present?
            # Якщо зображення не завантажиться, спрацює onerror і покаже заглушку
            image_tag image_url,
                      loading: "lazy",
                      class: "aa-shoe-image",
                      onerror: "this.style.display='none';this.nextElementSibling.style.display='flex';"
            div class: "aa-shoe-fallback", style: "display: none;" do
              span "No Photo"
            end
          else
            div class: "aa-shoe-fallback" do
              span "No Photo"
            end
          end
        end

        div class: "aa-shoe-body" do
          if shoe.brand
            div shoe.brand.name, class: "aa-shoe-brand"
          end

          h3 link_to(truncate(shoe.name, length: 45), admin_shoe_path(shoe)), class: "aa-shoe-title", title: shoe.name

          div class: "aa-shoe-meta" do
            span "ID: #{shoe.id}"
            if shoe.product_url.present?
              link_to "Source ↗", shoe.product_url, target: "_blank", class: "aa-meta-link"
            end
          end
        end

        div class: "aa-shoe-footer" do
          link_to "Edit", edit_admin_shoe_path(shoe), class: "aa-btn edit"
        end
      end
    end
  end
end