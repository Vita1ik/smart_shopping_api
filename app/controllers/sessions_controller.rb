class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def google_auth
    auth_info = request.env['omniauth.auth']

    user = User.find_or_create_by(email: auth_info['info']['email']) do |u|
      u.first_name = auth_info['info']['first_name']
      u.last_name = auth_info['info']['last_name']
      u.google_uid = auth_info['uid']
      u.password = SecureRandom.hex(10)
    end

    if user.persisted?
      token = JWT.encode(payload, Rails.application.secrets.secret_key_base)
      render json: {
        token: token,
        exp: 24.hours.from_now.to_i,
        user: Presenters::User.new(user).as_json,
      }, status: :ok
    else
      render json: { error: 'Authentication failed' }, status: 422
    end
  end

  def failure
    render json: { error: 'Authentication failed' }, status: 401
  end
end
