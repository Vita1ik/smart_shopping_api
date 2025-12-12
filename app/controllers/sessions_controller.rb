class SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def google_auth
    auth_info = request.env['omniauth.auth']

    puts auth_info

    user = User.find_or_create_by(email: auth_info['info']['email']) do |u|
      u.first_name = auth_info['info']['first_name']
      u.last_name = auth_info['info']['last_name']
      u.google_uid = auth_info['uid']
      u.avatar = auth_info['info']['image']
      u.password = SecureRandom.hex(10)
    end

    if user.persisted?
      payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
      token = JWT.encode(payload, Rails.application.secret_key_base)
      frontend_url = "https://smart-shopping-frontend.netlify.app/oauth/callback?token=#{token}"

      redirect_to frontend_url, allow_other_host: true
    else
      render json: { error: user.errors.full_messages }, status: 422
    end
  end

  def failure
    render json: { error: 'Authentication failed' }, status: 401
  end
end
