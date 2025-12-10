class SessionsController < ApplicationController
  # skip_before_action :verify_authenticity_token

  def google_auth
    auth_info = request.env['omniauth.auth']

    user = User.find_or_create_by(email: auth_info['info']['email']) do |u|
      u.name = auth_info['info']['name']
      u.google_uid = auth_info['uid']
      u.password = SecureRandom.hex(10)
    end

    payload = { user_id: user.id, exp: 24.hours.from_now.to_i }
    token = JWT.encode(payload, Rails.application.secrets.secret_key_base)

    render json: { token: token, user: { id: user.id, name: user.name, email: user.email } }
  end

  def failure
    render json: { error: 'Authentication failed' }, status: 401
  end
end
