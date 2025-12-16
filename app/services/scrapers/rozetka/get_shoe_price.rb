module Scrapers
  module Rozetka
    class GetShoePrice < Scrapers::Base::Scraper
      def initialize(shoe)
        @product_url = shoe.product_url
      end

      def run
        ::Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
          browser = playwright.chromium.launch(
            headless: true,
            args: [
              '--disable-blink-features=AutomationControlled',
              '--no-sandbox',
              '--disable-setuid-sandbox',
              '--disable-infobars',
              '--window-position=0,0',
              '--ignore-certificate-errors',
              '--ignore-certificate-errors-spki-list'
            ]
          )

          context = browser.new_context(
            userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
            viewport: { width: 1920, height: 1080 },
            locale: 'uk-UA',
            timezoneId: 'Europe/Kiev',
            permissions: ['geolocation'],
            extraHTTPHeaders: {
              'Accept-Language' => 'uk-UA,uk;q=0.9,en-US;q=0.8,en;q=0.7',
              'sec-ch-ua' => '"Google Chrome";v="123", "Not:A-Brand";v="8", "Chromium";v="123"',
              'sec-ch-ua-mobile' => '?0',
              'sec-ch-ua-platform' => '"Windows"'
            }
          )

          context.add_init_script(script: "Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")

          page = context.new_page
          page.set_default_timeout(60000)

          page.goto(@product_url)
          page.wait_for_load_state

          main_info = page.locator('rz-product-main-info')

          current_price_raw = main_info.locator('.product-price__big').inner_text

          old_price_locator = main_info.locator('.product-price__small')
          old_price_raw = old_price_locator.count > 0 ? old_price_locator.inner_text : nil

          # Rozetka often displays a third price for using their specific payment method
          # red_price_locator = main_info.locator('.red-price')
          # red_price_raw = red_price_locator.count > 0 ? red_price_locator.inner_text : nil

          current_price = current_price_raw.gsub(/[^\d]/, '').to_i
          old_price = old_price_raw ? old_price_raw.gsub(/[^\d]/, '').to_i : current_price
          # red_price = red_price_raw ? red_price_raw.gsub(/[^\d]/, '').to_i : nil

          puts "--- Extracted Data (Rozetka) ---"
          puts "Current Price: #{current_price} UAH"
          puts "Old Price:     #{old_price} UAH"

          browser.close
          return current_price || old_price
        end
      end
    end
  end
end