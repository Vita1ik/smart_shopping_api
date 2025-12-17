class SearchShoes
  SCRAPERS = {
    answear: Scrapers::Answear::Scraper,
    intertop: Scrapers::Intertop::Scraper,
    miraton: Scrapers::Miraton::Scraper,
    rozetka: Scrapers::Rozetka::Scraper,
  }.freeze

  def initialize(search, source_name)
    @search = search
    @source_name = source_name
  end

  def call
    results = perform_search(search)
    create_shoes(results)
  end

  private

  attr_reader :search, :source_name

  def perform_search(search)
    SCRAPERS[source_name.to_sym].new(search).run
  end

  def create_shoes(results)
    size_id = search.size_ids&.first
    brand_id = search.brand_ids&.first
    category_id = search.category_ids&.first
    color_id = search.color_ids&.first
    target_audience_id = search.target_audience_ids&.first
    source = Source.find_by(name: source_name)

    results.each do |result|
      shoe = Shoe.new(
        size_id:, brand_id:, category_id:, color_id:, target_audience_id:,
        name: result['title'],
        price: result['price']&.gsub(/\D/, '')&.to_i,
        product_url: result['link'],
        images: result['images'] || [result['image']],
        source:
      )
      shoe.searches = (shoe.searches || []) << search
      shoe.save
      UserShoe.create(shoe_id: shoe.id, user_id: search.user_id, current_price: shoe.price)
    end
  end
end