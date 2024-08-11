class ApplicationController < ActionController::API
  include Response

  before_action :authenticate_user

  private

  def authenticate_user
    @current_user, @decoded_token = Jwt::Authenticator.call(
      headers: request.headers
    )
  rescue StandardError => e
    render_unauthorized(e)
  end
end
