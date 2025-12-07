module Scrapers
  module Miraton
    class Scraper < Scrapers::Base::Scraper
      def run
        page.goto('https://www.miraton.ua/ua/search/?q=nike%20чорні%20кеди')

        sleep 7

        products_data = page.locator('.product-item').evaluate_all(<<~JS)
          items => items.map(item => {
            const title = item.querySelector('.product-name a')?.textContent.trim() || null;
    
            const brand = item.querySelector('.product-brand span')?.textContent.trim() || null;
    
            const link = item.querySelector('.product-name a')?.getAttribute('href') || null;
    
            const price_old = item.querySelector('.price-old span')?.textContent.trim() || null;
    
            const price_current = item.querySelector('.price-current')?.textContent.trim() || null;
    
            const images = Array.from(item.querySelectorAll('.product-img img'))
                  .map(img => img.getAttribute('src'))
                  .filter(Boolean);
        
                return {
                  title,
                  brand,
                  link,
                  price_old,
                  price_current,
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