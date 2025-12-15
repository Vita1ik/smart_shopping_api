class ScrapeShoesJob < ApplicationJob
  queue_as :scrapers

  def perform(search_id)
    search = Search.find(search_id)
    sources_names = Source.pluck(:name)

    sources_names.each { SearchShoes.new(search, _1).call }
  end
end