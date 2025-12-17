module Scrapers
  module Miraton
    class Scraper < Scrapers::Base::Scraper
      FILTER_MAPPING = {
        brand: "Бренд",
        size: "Розмір взуття",
        color: "Колір",
        category: "Тип взуття"
      }

      URLS = {
        men: 'https://www.miraton.ua/ua/catalog/men/shoes/',
        women: 'https://www.miraton.ua/ua/catalog/women/shoes/'
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
          page.wait_for_load_state

          # 1. Apply Filters
          filters.each do |key, value|
            next if [:price_min, :price_max].include?(key)

            category_label = FILTER_MAPPING[key]
            if category_label
              apply_filter(page, category_label, value)
            end
          end

          if filters[:price_min] && filters[:price_max]
            set_price_range(page, filters[:price_min], filters[:price_max])
          end

          force_submit(page)

          puts "--- Scraping Visible Products ---"
          products = scrape_products(page)

          puts "Found #{products.count} products."
          puts "Current URL: #{page.url}"
          puts products.first if products.any?

          browser.close
          return products
        end
      end

      def apply_filter(page, category_name, item_name)
        puts "  > Applying: [#{category_name}] -> #{item_name}"

        title_selector = ".bx-filter-parameters-box-title:has-text('#{category_name}')"
        filter_box = page.locator(".bx-filter-parameters-box").filter(has: page.locator(title_selector)).first

        return puts("    ! Error: Filter '#{category_name}' not found.") if filter_box.count == 0

        content_block = filter_box.locator(".bx-filter-block")
        unless content_block.visible?
          filter_box.locator(".bx-filter-parameters-box-title").click
          content_block.wait_for(state: 'visible', timeout: 5000)
        end

        option_span = filter_box.locator(".bx-filter-param-text[title='#{item_name}']").first
        option_span = filter_box.locator(".bx-filter-param-text:text-is('#{item_name}')").first if option_span.count == 0

        if option_span.count > 0
          option_span.scroll_into_view_if_needed rescue nil
          wrapper = option_span.locator("xpath=ancestor::label").first
          input = wrapper.locator("input[type='checkbox']")

          if input.evaluate("el => el.checked")
            puts "    - Already selected."
          else
            wrapper.click

            puts "    - Waiting for Bitrix debounce..."
            page.wait_for_timeout(1000)
          end
        else
          puts "    ! Error: Option '#{item_name}' not found."
        end
      end

      def set_price_range(page, min, max)
        puts "  > Setting Price: #{min} - #{max}"

        price_box = page.locator(".bx-filter-parameters-box[data-idprop='800']")
        if price_box.count > 0
          content = price_box.locator(".bx-filter-block")
          unless content.visible?
            price_box.locator(".bx-filter-parameters-box-title").click
            content.wait_for(state: 'visible')
          end
        end

        input_min = page.locator("#arrFilter_P1_MIN")
        input_max = page.locator("#arrFilter_P1_MAX")

        if input_min.count > 0
          input_min.fill("")
          input_min.type(min.to_s, delay: 50)
          page.keyboard.press("Enter")

          page.wait_for_timeout(1000)

          input_max.fill("")
          input_max.type(max.to_s, delay: 50)
          page.keyboard.press("Enter")

          page.wait_for_timeout(1000)
        end
      end

      def force_submit(page)
        puts "  > Forcing Filter Submission..."

        begin
          page.evaluate("setFilter()")
          page.wait_for_load_state
          page.wait_for_timeout(2000)
        rescue => e
          btn = page.locator("#set_filter, .apply-filter-button").first
          if btn.count > 0
            btn.click(force: true)
            page.wait_for_load_state
            page.wait_for_timeout(2000)
          end
        end
      end

      def scrape_products(page)
        page.locator(".product-item").evaluate_all(<<~JS)
          tiles => tiles.map(tile => {
            const titleElement = tile.querySelector(".product-name a");
    
            let priceElement = tile.querySelector(".price-current");
            if (!priceElement) {
               priceElement = tile.querySelector(".price");
            }
    
            const imgElement = tile.querySelector(".product-img img");
    
            const title = titleElement ? titleElement.textContent.trim() : "Unknown Title";
    
            const price = priceElement ? priceElement.textContent.trim().replace(/\\s+/g, ' ') : "";
    
            const link = titleElement ? titleElement.href : "";
    
            let image = imgElement ? (imgElement.src || imgElement.dataset.src) : "";
            
            if (image.startsWith("/upload")) {
              image = "https://www.miraton.ua" + image;
            }
    
            return { title, price, link, image };
          })
        JS
      end
    end
  end
end