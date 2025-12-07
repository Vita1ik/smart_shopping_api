module Api
  module V1
    class AuthController < ApplicationController
      # POST /api/v1/sign_up
      def sign_up
        user = User.new(user_params)

        if user.save
          token = encode_token(user.id)
          render json: { email: user.email, token: token }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/sign_in
      def sign_in
        user = User.find_by(email: params[:email])

        if user&.authenticate(params[:password])
          token = encode_token(user.id)
          render json: { email: user.email, token: }, status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      private

      def user_params
        params.permit(:email, :password, :first_name, :last_name)
      end

      def encode_token(user_id)
        payload = { user_id:, exp: 30.days.from_now.to_i }
        JWT.encode(payload, Rails.application.secret_key_base)
      end
    end
  end
end
