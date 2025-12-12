module Api
  module V1
    class SearchesController < ApiController
      before_action :authenticate_user!

      def create
        search = Search.new(search_params)
        search.user = current_user
        if search.valid?
          results = Scrapers::Intertop::Scraper.new(search).run
          search.results = results
          search.save
          render_ok(results)
        else
          render_unprocessable_entity(object)
        end
      end

      private

      def search_params
        params.permit(
          :size_ids,
          :brand_ids,
          :category_ids,
          :color_ids,
          :target_audience_ids,
          price_range: []
        )
      end
    end
  end
end
