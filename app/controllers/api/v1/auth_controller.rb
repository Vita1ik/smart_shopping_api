module Api
  module V1
    class AuthController < ApiController
      # POST /api/v1/sign_up
      def sign_up
        user = User.new(user_params)

        if user.save
          token = encode_token(user.id)
          render json: {
            user: Presenters::User.new(user).as_json,
            token: token
          }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/sign_in
      def sign_in
        user = User.find_by(email: params[:email])

        if user&.valid_password?(params[:password])
          token = encode_token(user.id)

          render json: {
            user: Presenters::User.new(user).as_json,
            token: token
          }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      private

      def encode_token(user_id)
        payload = { user_id:, exp: 24.hours.from_now.to_i }
        JWT.encode(payload, Rails.application.secret_key_base)
      end

      def user_params
        params.permit(:email, :password)
      end
    end
  end
end
