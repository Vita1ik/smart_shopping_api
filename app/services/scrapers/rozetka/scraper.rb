module Scrapers
  module Rozetka
    class Scraper < Scrapers::Base::Scraper
      def run
        page.goto('https://rozetka.com.ua/ua/shoes/c458425/')

        # Click the search input
        page.get_by_placeholder("Я шукаю...").click
        sleep(0.25)  # simulate slow_mo delay

        # Type the text slowly, like slow_mo
        "nike air force 1".each_char do |char|
          page.keyboard.type(char)
          sleep(rand)  # adjust typing speed
        end
        sleep(0.5)  # optional pause before screenshot
        # Press Enter and wait for navigation
        page.expect_navigation do
          page.keyboard.press("Enter")
        end
      ensure
        browser&.close
      end
    end
  end
end