module Scrapers
  SOURCE_MAPPINGS = {
    'answear' => Scrapers::Answear::GetShoePrice,
    'rozetka' => Scrapers::Rozetka::GetShoePrice,
    'miraton' => Scrapers::Miraton::GetShoePrice,
    'intertop' => Scrapers::Intertop::GetShoePrice
  }.freeze

  def self.get_shoe_price(shoe)
    Scrapers::SOURCE_MAPPINGS[shoe.source.name].new(shoe).run
  end
end