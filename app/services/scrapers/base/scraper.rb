require 'playwright'
require 'pry'

module Scrapers
  module Base
    class Scraper
      def initialize(search)
        @pw = Playwright.create(playwright_cli_executable_path: 'npx playwright')
        @browser = @pw.playwright.chromium.launch(headless: false)
        @page = browser.new_page
        @search = search
      end

      private

      attr_reader :page, :browser, :search

      delegate :price_max, :price_min, to: :search

      def brand = search.brands.first&.name
      def size = search.sizes.first&.name
      def color = search.colors.first&.name
      def category = search.categories.first&.name
      def target_audience = search.target_audiences.first&.name

      def filters
        {
          brand: ,
          size: ,
          color: ,
          category: ,
          target_audience: ,
          price_min: ,
          price_max:
        }
      end
    end
  end
end