module Api
  module V1
    class SearchesController < ApiController
      before_action :authenticate_user!

      def index
        render_ok(current_user.searches.with_filters.map { ::Presenters::Search.new(_1).as_json })
      end

      def create
        search = ::Search.new(search_params)
        search.user = current_user
        if search.save
          Source.pluck(:name)
                .each { ScrapeShoesJob.perform_async(search.id, _1) }
          render_ok(search_id: search.id)
        else
          render_unprocessable_entity(search)
        end
      end

      private

      def search_params
        params.permit(
          :price_min,
          :price_max,
          size_ids: [],
          brand_ids: [],
          category_ids: [],
          color_ids: [],
          target_audience_ids: []
        )
      end
    end
  end
end
