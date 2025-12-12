module Scrapers
  module Intertop
    class Scraper < Scrapers::Base::Scraper
      def run
        gender = 'men'
        gender = 'women' if target_audience&.woman?
        page.goto("https://intertop.ua/uk-ua/shopping/catalog/#{gender}/shoes/")

        query = category.name if category
        query += " #{brand.name}" if brand
        query += " #{color.name}" if color


        page.type('input[placeholder="Пошук модних знахідок"]', query)
        # sleep 3
        page.keyboard.press("Enter")

        page.locator(".in-product-tile").evaluate_all(<<~JS)
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

      def brand = search.brands.first
      # def size = search.sizes.first
      def color = search.colors.first
      def category = search.categories.first
      def target_audience = search.target_audiences.first
    end
  end
end