ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do

    # --- CSS Styles for Dashboard ---
    # Можна винести в окремий SCSS файл
    style do
      "
      .kpi-card {
        background: #fff;
        border-radius: 8px;
        padding: 20px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        text-align: center;
        border: 1px solid #e5e7eb;
      }
      .kpi-value { font-size: 2rem; font-weight: 700; color: #1f2937; }
      .kpi-label { font-size: 0.85rem; text-transform: uppercase; color: #6b7280; margin-top: 5px; letter-spacing: 0.5px; }
      .kpi-change { font-size: 0.8rem; margin-top: 5px; font-weight: 500; }
      .text-green { color: #10b981; }
      .text-gray { color: #9ca3af; }

      .chart-container {
        background: #fff;
        padding: 20px;
        border-radius: 8px;
        border: 1px solid #e5e7eb;
        box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        margin-bottom: 20px;
      }
      .panel-title { font-size: 1.1rem; font-weight: 600; margin-bottom: 15px; color: #374151; }
      "
    end

    # --- 1. KPI SECTION (Ключові показники) ---
    columns do
      column do
        div class: "kpi-card" do
          div number_with_delimiter(Shoe.count), class: "kpi-value"
          div "Всього взуття", class: "kpi-label"
          div "+#{Shoe.where('created_at >= ?', 1.day.ago).count} за 24г", class: "kpi-change text-green"
        end
      end

      column do
        div class: "kpi-card" do
          div number_with_delimiter(User.count), class: "kpi-value"
          div "Користувачів", class: "kpi-label"
          div "+#{User.where('created_at >= ?', 1.day.ago).count} за 24г", class: "kpi-change text-green"
        end
      end

      column do
        div class: "kpi-card" do
          div number_with_delimiter(Search.count), class: "kpi-value"
          div "Пошуків", class: "kpi-label"
          div "Активність платформи", class: "kpi-change text-gray"
        end
      end

      column do
        div class: "kpi-card" do
          # Середня ціна взуття (ділимо на 100, бо cents)
          avg_price = Shoe.average(:price).to_f / 100
          div number_to_currency(avg_price, unit: "₴", precision: 0), class: "kpi-value"
          div "Середня ціна товару", class: "kpi-label"
        end
      end
    end

    # --- 2. CHARTS SECTION (Графіки) ---
    columns do
      # Графік додавання взуття (показує роботу парсера)
      column span: 2 do
        div class: "chart-container" do
          h3 "Динаміка додавання взуття (за 30 днів)", class: "panel-title"
          div line_chart Shoe.group_by_day(:created_at, last: 30).count, colors: ["#2563eb"], height: "250px"
        end
      end

      # Графік пошуків (показує активність юзерів)
      column do
        div class: "chart-container" do
          h3 "Кількість пошуків", class: "panel-title"
          div column_chart Search.group_by_day(:created_at, last: 14).count, colors: ["#f59e0b"], height: "250px"
        end
      end
    end

    # --- 3. INSIGHTS SECTION (Корисна аналітика) ---
    columns do

      # Топ Брендів (Pie Chart)
      # Припускаємо, що у вас є модель Brand і зв'язок belongs_to :brand
      column do
        div class: "chart-container" do
          h3 "Топ 10 Брендів у базі", class: "panel-title"
          # Якщо моделі Brand немає, замініть на Shoe.group(:brand_id)
          data = Shoe.joins(:brand).group('brands.name').order('count_all DESC').limit(10).count
          div pie_chart data, donut: true, height: "300px", legend: "right"
        end
      end

      # Останні пошуки (Таблиця)
      column span: 2 do
        div class: "chart-container" do
          h3 "Останні пошукові запити", class: "panel-title"

          table_for Search.order(created_at: :desc).limit(8) do
            column("Дата") { |search| search.created_at.strftime("%d.%m %H:%M") }
            column("Користувач") { |search| link_to(search.user.email, admin_user_path(search.user)) }
            column("Фільтри") do |search|
              # Форматування цінового діапазону для зручності
              min = search.price_min ? "#{search.price_min}₴" : "0"
              max = search.price_max ? "#{search.price_max}₴" : "∞"
              span "#{min} - #{max}", class: "status_tag yes" # active_admin style tag
            end
          end
        end
      end
    end

    # --- 4. Users Demographics (Optional) ---
    columns do
      column do
        div class: "chart-container" do
          h3 "Середня ціна взуття по магазинах", class: "panel-title"
          # Рахуємо середню ціну, ділимо на 100 (бо в базі копійки), сортуємо
          data = Shoe.joins(:source).group('sources.name').average('price / 100.0').sort_by { |_k, v| v }.reverse
          div bar_chart data, prefix: "₴", height: "300px", colors: ["#6366f1"]
        end
      end

      column do
        div class: "chart-container" do
          h3 "Розподіл користувачів за розміром ноги", class: "panel-title"
          # Припускаємо, що є Size модель
          if defined?(Size)
            data = User.joins(:size).group('sizes.name').count
            div column_chart data, height: "200px", colors: ["#10b981"]
          else
            div "Немає даних про розміри", style: "padding: 20px; text-align: center; color: #999;"
          end
        end
      end
    end

    columns do
      # Графік 3: Моніторинг парсерів (хто що додав за тиждень)
      column span: 2 do
        div class: "chart-container" do
          h3 "Активність магазинів (додано взуття за останні 7 днів)", class: "panel-title"
          # Цей графік покаже, якщо якийсь магазин "впав" в нуль
          data = Shoe.where('shoes.created_at > ?', 7.days.ago)
                     .joins(:source)
                     .group('sources.name')
                     .group_by_day('shoes.created_at')
                     .count
          div line_chart data, height: "300px", legend: "bottom"
        end
      end
    end

  end # content
end