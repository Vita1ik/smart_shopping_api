class ScrapeShoesJob
  include Sidekiq::Job

  sidekiq_options queue: :scrapers, retry: false

  def perform(search_id, source_name)
    search = Search.find(search_id)

    SearchShoes.new(search, source_name).call
  end
end