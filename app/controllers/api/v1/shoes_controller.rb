module Api
  module V1
    class ShoesController < ApiController
      before_action :authenticate_user!, except: [:redirect_from_email]

      # get
      def index
        shoes = ::Shoe.by_search_id(params.require(:search_id))
        result = shoes.map { Presenters::Shoe.new(_1).as_json }
        render_ok(result)
      end

      def redirect_from_email
        shoe_id = params.require(:shoe_id)
        user_id = params.require(:user_id)
        user_shoe = UserShoe.find_by(user_id:, shoe_id:)
        user_shoe.update(visited_discounted_from_email: true)

        redirect_to user_shoe.shoe.product_url, allow_other_host: true
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
        user_shoes = UserShoe.where(user_id: current_user.id, liked: true).includes(:shoe)
        result = user_shoes.map do
          Presenters::Shoe.new(_1.shoe).as_json.merge(
            current_price: _1.current_price,
            prev_price: _1.prev_price,
            discounted: _1.discounted
          )
        end
        render_ok(result)
      end
    end
  end
end
