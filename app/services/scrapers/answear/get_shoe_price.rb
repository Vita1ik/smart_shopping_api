require 'playwright'

module Scrapers
  module Answear
    class GetShoePrice
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

          price_container = page.locator('[data-test="priceSaleWithoutMinimalDesktop"]')

          current_price_raw = price_container.locator('div[class^="ProductCard__priceSale"]').inner_text
          old_price_raw = price_container.locator('div[class^="ProductCard__priceRegular"]').inner_text

          current_price = current_price_raw.gsub(/[^\d]/, '').to_i
          old_price = old_price_raw.gsub(/[^\d]/, '').to_i

          puts "--- Extracted Data ---"
          puts "Raw Current: #{current_price_raw}"
          puts "Raw Old:     #{old_price_raw}"
          puts "----------------------"
          puts "Clean Integer: #{current_price}"
          puts "Clean Old:     #{old_price}"

          browser.close
          return current_price || old_price
        end
      end
    end
  end
end