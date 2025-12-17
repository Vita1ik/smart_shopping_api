module Api
  module V1
    class ShoesController < ApiController
      before_action :authenticate_user!

      # get
      def index
        shoes = ::Shoe.by_search_id(params.require(:search_id))
        result = shoes.map { Presenters::Shoe.new(_1).as_json }
        render_ok(result)
      end

      # post
      def like
        shoe_id = params.require(:shoe_id)
        user_shoe = UserShoe.find_by(user_id: current_user.id, shoe_id:)
        if user_shoe
          user_shoe.like!
          SaleMonitoringJob.perform_in(12.hours, user_shoe.id)
          render_ok
        else
          render_not_found(errors: 'User shoe not found')
        end
      end

      # post
      def dislike
        shoe_id = params.require(:shoe_id)
        user_shoe = UserShoe.find_by(user_id: current_user.id, shoe_id:)
        if user_shoe
          user_shoe.dislike!
          render_ok
        else
          render_not_found(errors: 'User shoe not found')
        end
      end

      # get
      def liked
        user_shoes = UserShoe.where(user_id: current_user.id, liked: true).includes(:shoes)
        result = user_shoes.map do
          Presenters::Shoe.new(_1.shoe).as_json.merge(
            current_price: user_shoes.current_price,
            prev_price: user_shoes.prev_price,
            discounted: user_shoes.prev_price
          )
        end
        render_ok(result)
      end
    end
  end
end
