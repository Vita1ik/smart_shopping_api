module Scrapers
  module Intertop
    class Scraper < Scrapers::Base::Scraper
      FILTER_MAPPING = {
        brand: "Бренд",
        size: "Розмір",
        color: "Колір"
      }

      URLS = {
        men: 'https://intertop.ua/uk-ua/shopping/catalog/men/shoes/',
        women: 'https://intertop.ua/uk-ua/shopping/catalog/women/shoes/'
      }

      def run
        Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
          browser = playwright.chromium.launch(headless: true)
          context = browser.new_context
          page = context.new_page

          target_audience = target_audience&.to_sym || :men
          target_url = URLS[target_audience]
          puts "--- Navigating to #{target_audience.capitalize} Catalog ---"
          page.goto(target_url)

          if filters[:category]
            success = select_category(page, filters[:category])
            unless success
              puts "!!! Critical: Category '#{filters[:category]}' not found. Aborting."
              browser.close
              return []
            end
          end

          show_all_filters(page)

          filters.each do |key, value|
            next if [:category, :price_min, :price_max].include?(key)

            category_label = FILTER_MAPPING[key]
            if category_label
              success = apply_filter(page, category_label, value)
              unless success
                puts "!!! Critical: Filter '#{key}: #{value}' failed. Aborting."
                browser.close
                return []
              end
            else
              puts "Warning: Unknown filter key '#{key}'"
            end
          end

          if filters[:price_min] && filters[:price_max]
            set_price_range(page, filters[:price_min], filters[:price_max])
          end

          puts "--- Scraping Visible Products ---"
          products = scrape_products(page)

          puts "Found #{products.count} products."
          puts products.first if products.any?

          browser.close
          return products
        end
      end

      def select_category(page, category_name)
        puts "  > Selecting Category: '#{category_name}'"

        matcher = /#{Regexp.escape(category_name)}/i
        link = page.locator(".in-category-item__link").filter(hasText: matcher).first

        if link.count > 0
          link.click
          page.wait_for_load_state
          puts "    - Navigated to category page."
          return true
        else
          puts "    ! Error: Category '#{category_name}' not found."
          return false
        end
      end

      def show_all_filters(page)
        show_more_btn = page.locator(".in-button-text-icon__label:text-is('Показати ще')")
        if show_more_btn.count > 0 && show_more_btn.first.visible?
          puts "  > Expanding filter sidebar..."
          show_more_btn.first.click
          page.wait_for_timeout(1000)
        end
      end

      def apply_filter(page, category_name, item_name)
        puts "  > Applying: [#{category_name}] -> #{item_name}"
        show_all_filters(page)

        accordion = page.locator(".in-drop-accordion")
                        .filter(has: page.locator(".in-drop-accordion__label-text:text-is('#{category_name}')"))
                        .first

        if accordion.count == 0
          puts("    ! Error: Filter group '#{category_name}' not found.")
          return false
        end

        button = accordion.locator(".in-drop-accordion__label button.in-button").first
        content = accordion.locator(".in-drop-accordion__content")

        unless content.visible?
          button.click
          content.wait_for(state: 'visible')
        end

        if category_name == "Розмір"
          val_esc = Regexp.escape(item_name)
          matcher = /^#{val_esc}([\.\,\s]\d|\s\d\/\d)*(?!.*-)/i
          puts "    - Using Fuzzy Size Logic..."
        else
          matcher = /#{Regexp.escape(item_name)}/i
        end

        checkboxes = content.locator(".in-facet-item__label").filter(hasText: matcher).all
        buttons    = content.locator("a.in-facet-option-item").filter(hasText: matcher).all

        matches = checkboxes + buttons

        if matches.empty?
          puts "    ! Error: Option '#{item_name}' not found."
          return false
        end

        puts "    + Found #{matches.count} matching options."
        any_clicked = false

        matches.each do |el|
          txt = el.text_content.strip

          next if category_name == "Розмір" && txt.include?("-")

          puts "    -> Selecting: #{txt}"
          el.scroll_into_view_if_needed rescue nil
          el.click

          page.wait_for_timeout(2000)
          any_clicked = true
        end

        return any_clicked
      end

      def set_price_range(page, min, max)
        puts "  > Setting Price: #{min} - #{max}"
        show_all_filters(page)

        accordion = page.locator(".in-drop-accordion").filter(has: page.locator(".in-drop-accordion__label-text:text-is('Ціна')")).first
        button = accordion.locator(".in-drop-accordion__label button.in-button").first
        content = accordion.locator(".in-drop-accordion__content")

        unless content.visible?
          button.click
          content.wait_for(state: 'visible')
        end

        range_box = content.locator(".in-facet-range-dropdown__range-box").first

        if range_box.count > 0
          range_box.locator("input").first.fill(min.to_s)
          range_box.locator("input").nth(1).fill(max.to_s)
          range_box.locator("button:text-is('Ok')").click
          page.wait_for_timeout(2500)
        end
      end

      def scrape_products(page)
        page.locator(".in-product-tile").evaluate_all(<<~JS)
          tiles => tiles.map(tile => {
            const title = tile.querySelector(".in-product-tile__product-brand")?.textContent.trim();
            const price = (tile.querySelector(".in-product-price__actual, .in-product-price__regular")?.textContent || "").trim();
            const link = tile.querySelector(".in-product-tile__details-link")?.href;
            const images = Array.from(tile.querySelectorAll(".in-picture__img")).map(img => img.src || img.dataset.src);
            return { title, price, link, images };
          })
        JS
      end
    end
  end
end