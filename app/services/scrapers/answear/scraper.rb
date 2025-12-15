module Scrapers
  module Answear
    class Scraper < Scrapers::Base::Scraper
      FILTER_MAPPING = {
        brand: "[data-test='brandsFilter']",
        size: "[data-test='size_filters'] [data-test='multiSelectFilterArrow']",
        color: "[data-test='color_filters'] [data-test='multiSelectFilterArrow']",
        price: "[data-test='priceFilter']",
        category: "[data-test='category_filters'] [data-test='multiSelectFilterArrow']"
      }

      URLS = {
        men: 'https://answear.ua/k/vin/vzuttya',
        women: 'https://answear.ua/k/vona/vzuttya'
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
          sleep(3)
          close_popups(page)

          filters.each do |key, value|
            next if [:price_min, :price_max].include?(key)

            selector = FILTER_MAPPING[key]
            apply_filter(page, selector, value) if selector
          end
          sleep(2)
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

      private

      def close_popups(page)
        selectors = ["button[data-test='cookiesAcceptButton']", ".NewModal__newModalClose__P_j3_"]
        selectors.each do |sel|
          el = page.locator(sel).first
          if el.count > 0 && el.visible?
            puts "  > Closing popup: #{sel}"
            el.click rescue nil
            page.wait_for_timeout(1000)
          end
        end
      end

      def apply_filter(page, selector, item_name)
        puts "  > Applying Filter via: #{selector}"
        header = page.locator(selector).first
        return unless header.count > 0

        begin
          header.click
        rescue
          close_popups(page)
          header.click(force: true)
        end

        search_input = page.locator("#baseSearch")
        if search_input.count > 0 && search_input.first.visible?
          puts "    - Searching for '#{item_name}'..."
          search_input.first.fill(item_name)
          page.wait_for_timeout(1000)
        end

        safe_name = item_name.gsub("'", "\\'")

        matching_items = page.locator("div[data-test='filterItem']:has-text('#{safe_name}')").all

        if matching_items.empty?
          puts "    ! Error: No items found containing '#{item_name}'."
          return
        end

        puts "    - Found #{matching_items.size} matching options. Selecting all..."

        matching_items.each do |item|
          item.scroll_into_view_if_needed

          input = item.locator("input[type='checkbox']")
          is_checked = input.evaluate("el => el.checked") rescue false

          if is_checked
            puts "      * Option already selected (skipping click)."
          else
            item.click
            page.wait_for_timeout(200)
          end
        end

        confirm_btn = page.locator("button[data-test='multiSelectSubmitButton']")
        if confirm_btn.count > 0 && confirm_btn.first.visible?
          puts "    - Clicking 'Ok'..."
          confirm_btn.first.click
          page.wait_for_timeout(2000)
        end
      end

      def set_price_range(page, min, max)
        puts "  > Setting Price: #{min} - #{max}"

        price_trigger = page.locator("[data-test='priceFilter']").first

        input_min = page.locator("#PriceFilterRangeInputMin")

        unless input_min.visible?
          price_trigger.click
          page.wait_for_timeout(500)
        end

        if input_min.count > 0
          puts "    - Filling Min: #{min}"
          input_min.fill("")
          input_min.fill(min.to_s)
        end

        input_max = page.locator("#PriceFilterRangeInputMax")
        if input_max.count > 0
          puts "    - Filling Max: #{max}"
          input_max.fill("")
          input_max.fill(max.to_s)
        end

        confirm_btn = page.locator("button[data-test='multiSelectSubmitButton']")

        visible_btn = confirm_btn.filter(has: page.locator("visible=true")).first

        if visible_btn.count > 0
          puts "    - Clicking 'Ok' for Price..."
          visible_btn.click
          page.wait_for_timeout(2500)
        else
          puts "    ! Error: Price 'Ok' button not found."
        end
      end

      def scrape_products(page)
        page.wait_for_selector("[data-test='productCard']", timeout: 5000) rescue nil

        page.locator("[data-test='productCard']").evaluate_all(<<~JS)
          cards => cards.map(card => {
            const titleEl = card.querySelector("[class*='productCardName']");
    
            let priceEl = card.querySelector("[class*='priceSale']");
            if (!priceEl) {
               priceEl = card.querySelector("[class*='priceRegular']");
            }
    
            const linkEl = card.querySelector("a[data-test='productItem']");
            const imgEl = card.querySelector("img");
    
            return {
              title: titleEl ? titleEl.innerText.trim() : null,
              price: priceEl ? priceEl.innerText.trim() : null,
              link: linkEl ? linkEl.href : null,
              image: imgEl ? (imgEl.src || imgEl.dataset.src) : null
            };
          }).filter(p => p.title)
        JS
      end
    end
  end
end