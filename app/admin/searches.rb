ActiveAdmin.register Search do
  # Оптимізація SQL запитів (N+1)
  includes :user, :brands, :categories, :sizes, :target_audiences

  # Забороняємо редагування, оскільки пошук - це історичний лог.
  # Якщо вам треба редагувати - видаліть рядок `except: [:edit, :update]`
  actions :all, except: [:edit, :update]

  # --- INDEX PAGE ---
  index do
    selectable_column
    id_column

    column :user

    column "Price Range" do |search|
      min = search.price_min || 0
      max = search.price_max ? "#{search.price_max}" : "∞"
      "#{min} - #{max} ₴"
    end

    column "Filters" do |search|
      # Показуємо короткий огляд вибраних фільтрів
      filters = []
      filters << "Brand: #{search.brands.first.name}" if search.brands.any?
      filters << "Size: #{search.sizes.first.name}" if search.sizes.any?
      filters << "Categ: #{search.categories.first.name}" if search.categories.any?

      filters.empty? ? span("No filters", class: "status_tag") : filters.join(", ")
    end

    column "Results Found" do |search|
      # Якщо у вас результати записані в jsonb як масив ID або count
      if search.results.is_a?(Array)
        search.results.count
      elsif search.shoes.any?
        search.shoes.count
      else
        span "0", class: "status_tag red"
      end
    end

    column :created_at
    actions
  end

  # --- FILTERS (SIDEBAR) ---
  filter :user
  filter :price_min
  filter :price_max
  filter :created_at

  # Фільтри по асоціаціях (дозволяють знайти "хто шукав Nike")
  filter :brands
  filter :categories
  filter :sizes
  filter :target_audiences

  # --- SHOW PAGE ---
  show do
    panel "Search Details" do
      attributes_table_for search do
        row :id
        row :user
        row :created_at
        row :price_range do
          "#{search.price_min} - #{search.price_max} ₴"
        end
      end
    end

    columns do
      # Ліва колонка - Критерії пошуку
      column span: 1 do
        panel "Search Criteria (Filters)" do
          attributes_table_for search do
            row :brands
            row :categories
            row :sizes
            row :colors
            row :target_audiences do |s|
              s.target_audiences.map(&:name).join(", ")
            end
          end
        end
      end
    end

    # Відображення знайденого взуття (через асоціацію shoes)
    panel "Associated Shoes Results (#{search.shoes.count})" do
      table_for search.shoes.includes(:brand) do
        column :id
        column :image do |shoe|
          if shoe.images&.first
            img src: shoe.images.first, style: "width: 100px; border-radius: 8px;"
          end
        end
        column :name do |shoe|
          link_to shoe.name, admin_shoe_path(shoe)
        end
        column :product_url do |shoe|
          link_to shoe.source.name, shoe.product_url
        end
        column :brand
        column :category
        column :size
        column :color
        column :price do |shoe|
          number_to_currency(shoe.price, unit: "₴")
        end
      end
    end
  end
end