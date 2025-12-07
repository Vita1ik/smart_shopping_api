module Scrapers
  module Answear
    class Scraper < Scrapers::Base::Scraper
      def run
        page.goto('https://answear.ua/k/vin/vzuttya')

        page.fill('input#productsSearch', 'кросівки nike air force 1')

        sleep(0.5)
        # Press Enter and wait for navigation
        page.expect_navigation do
          page.keyboard.press("Enter")
        end

        sleep(10.5)

        binding.pry
        products_data = page.locator('[data-test="productCard"]').evaluate_all(<<~JS)
          cards => cards.map(card => {
            const title = card.querySelector('[data-test="productCardDescription"] span')?.textContent.trim() || null;
      
            const link = card.querySelector('a[data-test="productItem"]')?.getAttribute('href') || null;
      
            const price_sale = card.querySelector('[class*="ProductItemPrice__priceSale"]')?.textContent.trim() || null;
      
            const price_regular = card.querySelector('[class*="ProductItemPrice__priceRegularWithSale"]')?.textContent.trim() || null;
      
            // Collect all <img> or <source> URLs
            const images = Array.from(card.querySelectorAll('picture source, picture img'))
              .map(img => img.getAttribute('srcset') || img.getAttribute('src'))
              .filter(Boolean);
      
            return {
              title,
              link,
              price_sale,
              price_regular,
              images
            };
          })
        JS
      ensure
        browser&.close
      end
    end
  end
end