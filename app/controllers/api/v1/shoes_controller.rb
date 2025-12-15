module Api
  module V1
    class ShoesController < ApiController
      before_action :authenticate_user!

      def index
        shoes = ::Shoe.by_search_id(params.require(:search_id))
        result = shoes.map { Presenters::Shoe.new(_1).as_json }
        render_ok(result)
      end
    end
  end
end
