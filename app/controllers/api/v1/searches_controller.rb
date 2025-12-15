module Api
  module V1
    class SearchesController < ApiController
      before_action :authenticate_user!

      def create
        search = ::Search.new(search_params)
        search.user = current_user
        if search.save
          ScrapeShoesJob.perform_async(search.id)
          render_ok(search_id: search.id)
        else
          render_unprocessable_entity(search)
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
          :price_min,
          :price_max
        )
      end
    end
  end
end
