require 'playwright'
require 'pry'

module Scrapers
  module Base
    class Scraper
      def initialize(search)
        @pw = Playwright.create(playwright_cli_executable_path: 'npx playwright')
        @browser = @pw.playwright.chromium.launch(headless: true)
        @page = browser.new_page
        @search = search
      end

      private

      attr_reader :page, :browser, :search
    end
  end
end