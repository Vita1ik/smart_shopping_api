module Scrapers
  module Rozetka
    class Scraper < Scrapers::Base::Scraper
      FILTER_MAPPING = {
        brand: "Бренд",
        size: "Розмір",
        color: "Колір",
        category: "Категорії товарів"
      }

      URLS = {
        men: 'https://rozetka.com.ua/ua/men_shoes/c721654/',
        women: 'https://rozetka.com.ua/ua/women_shoes/c721652/'
      }

      def run
        Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
          browser = playwright.chromium.launch(
            headless: false,
            args: [
              '--headless=new',
              '--disable-blink-features=AutomationControlled',
              '--no-sandbox',
              '--disable-setuid-sandbox',
              '--disable-infobars',
              '--window-position=0,0',
              '--ignore-certificate-errors',
              '--ignore-certificate-errors-spki-list',
              '--start-maximized'
            ]
          )

          context = browser.new_context(
            userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
            viewport: { width: 1920, height: 1080 },
            locale: 'uk-UA',
            timezoneId: 'Europe/Kiev',
            permissions: ['geolocation'],
            extraHTTPHeaders: {
              'Accept-Language' => 'uk-UA,uk;q=0.9',
              'sec-ch-ua-platform' => '"Windows"',
              'sec-ch-ua-mobile' => '?0'
            }
          )

          context.add_init_script(script: "Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")

          page = context.new_page
          page.set_default_timeout(60000)

          target_audience = target_audience&.to_sym || :men
          target_url = URLS[target_audience]
          puts "--- Navigating to #{target_audience.capitalize} Catalog ---"

          if page.title.include?("Just a moment") || page.locator("text=Human verification").count > 0
            puts "!!! CLOUDFLARE BLOCK DETECTED !!!"
            page.screenshot(path: 'block_error.png')
            browser.close
            return []
          end

          page.mouse.move(rand(0..500), rand(0..500))
          page.goto(target_url)

          if page.locator("text=Щось пішло не так").count > 0 || page.locator("text=500").count > 0
            puts "!!! BLOCK DETECTED (500 Error) !!!"
            browser.close
            return []
          end

          # Wait for sidebar
          page.wait_for_selector("rz-filter-stack", timeout: 20000) rescue nil

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

          puts "--- Scraping Visible Products ---"
          page.wait_for_selector("rz-product-tile", timeout: 10000) rescue nil

          products = scrape_products(page)

          puts "Found #{products.count} products."
          puts products.first if products.any?

          browser.close
          return products
        end
      end

      def apply_filter(page, category_name, item_name)
        puts "  > Applying: [#{category_name}] -> #{item_name}"

        summary_selector = "summary:has-text('#{category_name}')"
        sidebar_block = page.locator("details[data-testid='filter']").filter(has: page.locator(summary_selector)).first

        unless sidebar_block.count > 0
          puts "    ! Error: Filter block '#{category_name}' not found."
          return
        end

        unless sidebar_block.get_attribute("open")
          sidebar_block.locator("summary").click
          page.wait_for_timeout(500)
        end

        search_input = sidebar_block.locator("input.search-input").first
        if search_input.count > 0 && search_input.visible?
          puts "    - Searching..."
          search_input.fill(item_name)
          page.wait_for_timeout(1500)
        end

        option_link = sidebar_block.locator("a.checkbox-filter-link").filter(has: page.locator("text=#{item_name}")).first

        if option_link.count == 0
          option_link = sidebar_block.locator("a.link").filter(has: page.locator("text=#{item_name}")).first
        end

        if option_link.count > 0
          option_link.scroll_into_view_if_needed
          begin
            option_link.click
            wait_for_ajax(page)
          rescue => e
            puts "    ! Click failed: #{e.message}"
          end
        else
          puts "    ! Error: Option '#{item_name}' not found."
        end
      end

      def set_price_range(page, min, max)
        puts "  > Setting Price: #{min} - #{max}"

        price_block = page.locator("details[data-testid='filter']").filter(has: page.locator("summary:has-text('Ціна')")).first
        return unless price_block.count > 0

        unless price_block.get_attribute("open")
          price_block.locator("summary").click
        end

        input_min = price_block.locator("input[data-testid='filter_slider_min_input']").first
        input_max = price_block.locator("input[data-testid='filter_slider_max_input']").first
        submit_btn = price_block.locator("button[type='submit']").first

        if input_min.count > 0
          input_min.fill("")
          input_min.type(min.to_s, delay: 100)
        end

        if input_max.count > 0
          input_max.fill("")
          input_max.type(max.to_s, delay: 100)
        end

        if submit_btn.count > 0 && submit_btn.visible?
          submit_btn.click
        else
          input_max.press("Enter")
        end

        wait_for_ajax(page)
      end

      def wait_for_ajax(page)
        page.wait_for_timeout(3000)
      end

      def scrape_products(page)
        page.locator("rz-product-tile").evaluate_all(<<~JS)
          tiles => tiles.map(tile => {
            const titleEl = tile.querySelector(".tile-title");
    
            let priceEl = tile.querySelector(".price.color-red");
            if (!priceEl) {
               priceEl = tile.querySelector(".price");
            }
    
            const linkEl = tile.querySelector("a.tile-title") || tile.querySelector("a.tile-image-host");
            const imgEl = tile.querySelector(".tile-image");
    
            return {
              title: titleEl ? titleEl.innerText.trim() : "Unknown",
              price: priceEl ? priceEl.innerText.replace(/[^0-9]/g, '') : "0",
              link: linkEl ? linkEl.href : null,
              image: imgEl ? (imgEl.src || imgEl.dataset.src) : null
            };
          }).filter(p => p.title && p.link)
        JS
      end
    end
  end
end