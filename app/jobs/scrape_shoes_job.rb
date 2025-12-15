class ScrapeShoesJob
  include Sidekiq::Job

  sidekiq_options queue: :scrapers

  def perform(search_id)
    search = Search.find(search_id)
    sources_names = Source.pluck(:name)

    sources_names.each { SearchShoes.new(search, _1).call }
  end
end