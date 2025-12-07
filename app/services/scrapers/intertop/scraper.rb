module Scrapers
  module Intertop
    class Scraper < Scrapers::Base::Scraper
      def run
        page.goto('https://intertop.ua/uk-ua/shopping/catalog/men/shoes/')
        # Click the search input
        # page.get_by_placeholder("Пошук модних знахідок").click

        # Type the text
        # page.type('input[placeholder="Пошук модних знахідок"]', "adidas Supernova")
        page.type('input[placeholder="Пошук модних знахідок"]', "кросівки для бігу adidas чорні")

        page.keyboard.press("Enter")
        sleep 7

        # # Wait for the search results container to appear
        # begin
        #   page.locator(".product-card__image").wait_for(state: "visible")
        # rescue
        # end

        products_data = page.locator(".in-product-tile").evaluate_all(<<~JS)
          tiles => tiles.map(tile => {
            const title = tile.querySelector(".in-product-tile__product-brand")?.textContent.trim();
            const price = (tile.querySelector(".in-product-price__actual, .in-product-price__regular")?.textContent || "").trim();
            const link = tile.querySelector(".in-product-tile__details-link")?.href;
            const images = Array.from(tile.querySelectorAll(".in-picture__img")).map(function(img) {
              return img.src;
            });
    
            return { title, price, link, images };
          })
        JS
      ensure
        browser&.close
      end
    end
  end
end