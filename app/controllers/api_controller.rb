class ApiController < ActionController::API
  include Devise::Controllers::Helpers

  # Ensure we always respond with JSON
  respond_to :json

  def authenticate_user!
    header = request.headers['Authorization']
    return render_unauthorized("Token missing") unless header

    begin
      token = header.split(' ').last
      decoded = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')

      user_id = decoded[0]['user_id']
      @current_user = User.find(user_id)

    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render_unauthorized("Invalid token")
    end
  end

  # Helper for current_user (Devise uses this)
  def current_user
    @current_user
  end

  private

  def render_ok(json)
    render json:, status: :ok
  end

  def render_unauthorized(message)
    render json: { errors: message }, status: :unauthorized
  end

  def render_unprocessable_entity(object, errors: nil)
    render json: { errors: errors || object.errors.full_messages }, status: :unprocessable_entity
  end
end