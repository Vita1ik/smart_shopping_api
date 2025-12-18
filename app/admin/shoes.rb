ActiveAdmin.register Shoe do
  includes :brand, :size, :color, :target_audience, :source, :category

  permit_params :name, :price, :brand_id, :size_id, :color_id, :target_audience_id, :source_id, :category_id

  # --- FILTERS ---
  filter :name
  filter :brand, as: :searchable_select
  filter :source, as: :searchable_select
  filter :category, as: :searchable_select
  filter :color, as: :searchable_select
  filter :size, as: :searchable_select
  filter :target_audience, as: :check_boxes

  index as: :grid, columns: 5 do |shoe|
    div class: "aa-grid-item" do
      div class: "aa-shoe-card" do

        div class: "aa-shoe-header" do
          # Посилання на всю площу хедера
          link_to admin_shoe_path(shoe), class: "aa-shoe-link-overlay" do; end

          div number_to_currency(shoe.price, unit: "₴", precision: 0), class: "aa-shoe-price-badge"

          image_url = shoe.images&.first
          if image_url.present?
            img src: image_url,
                loading: "lazy",
                class: "aa-shoe-image"
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

  show do
    panel "Product Details" do
      columns do
        # Column 1: Main Image
        column span: 2 do
          if shoe.images.present?
            image_tag shoe.images.first, style: "width: 100%; max-width: 400px; border-radius: 8px; border: 1px solid #eee;"
          else
            div "No Image Available", style: "padding: 50px; background: #f4f4f4; text-align: center; color: #999;"
          end
        end

        # Column 2: Data Table
        column span: 3 do
          attributes_table_for shoe do
            row :name
            row :price do |shoe|
              number_to_currency(shoe.price, unit: "₴", precision: 0)
            end
            row :brand
            row :category
            row :color
            row :size
            row :target_audience
            row :source
            row :product_url do |shoe|
              if shoe.product_url.present?
                link_to shoe.product_url, shoe.product_url, target: "_blank"
              end
            end
            row :created_at
            row :updated_at
          end
        end
      end
    end

    # Bottom Gallery: If there are multiple images, show them in a row
    if shoe.images.present? && shoe.images.length > 1
      panel "Image Gallery" do
        div style: "display: flex; gap: 10px; flex-wrap: wrap;" do
          shoe.images.each do |img|
            span do
              image_tag img, style: "height: 100px; width: auto; border: 1px solid #ddd; border-radius: 4px;"
            end
          end
        end
      end
    end

    active_admin_comments
  end
end