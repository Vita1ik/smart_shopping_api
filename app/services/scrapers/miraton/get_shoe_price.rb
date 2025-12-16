module Scrapers
  module Miraton
    class GetShoePrice < Scrapers::Base::Scraper
      def initialize(shoe)
        @product_url = shoe.product_url
      end

      def run
        ::Playwright.create(playwright_cli_executable_path: 'npx playwright') do |playwright|
          browser = playwright.chromium.launch(headless: true)
          context = browser.new_context
          page = context.new_page

          page.goto(@product_url)
          page.wait_for_load_state
          price_container = page.locator('.item-price')

          current_price_raw = price_container.locator('.price').inner_text
          old_price_locator = price_container.locator('.old')

          if old_price_locator.count > 0
            old_price_raw = old_price_locator.inner_text
          else
            old_price_raw = nil
          end

          current_price = current_price_raw.gsub(/[^\d]/, '').to_i
          old_price = old_price_raw ? old_price_raw.gsub(/[^\d]/, '').to_i : current_price

          puts "--- Extracted Data ---"
          puts "Raw Current: #{current_price_raw}"
          puts "Raw Old:     #{old_price_raw}"

          browser.close
          return current_price || old_price
        end
      end
    end
  end
end