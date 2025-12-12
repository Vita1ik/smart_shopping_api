module Api
  module V1
    class UsersController < ApiController
      before_action :authenticate_user!

      def show
        render json: Presenters::User.new(current_user).as_json
      end

      def update
        if current_user.update(user_params)
          render json: Presenters::User.new(current_user).as_json, status: :ok
        else
          render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:first_name, :last_name, :size_id, :target_audience_id)
      end
    end
  end
end
