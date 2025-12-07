require 'playwright'
require 'pry'

module Scrapers
  module Base
    class Scraper
      def initialize
        @pw = Playwright.create(playwright_cli_executable_path: 'npx playwright')
        @browser = @pw.playwright.chromium.launch(headless: false)
        @page = browser.new_page
      end

      private

      attr_reader :page, :browser
    end
  end
end