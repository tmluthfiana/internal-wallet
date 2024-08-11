class Api::V1::AuthenticationController < ApplicationController
  skip_before_action :authenticate_user
  before_action :authenticate_refresh_token, only: [:refresh_token]

  def sign_in
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      access_token, refresh_token, exp = Jwt::Issuer.call(user)
      render_raw_response(succeed_payload(access_token:, refresh_token:, exp:), status: :ok)
    else
      render_unauthorized(StandardError.new('Invalid email or password'))
    end
  end

  def refresh_token
    if params[:refresh_token].blank?
      raise Jwt::Errors::MissingToken.new(token: 'refresh_token')
    end

    access_token, refresh_token, exp = Jwt::Refresher.refresh!(params[:refresh_token], @decoded_token, @current_user)
    render_raw_response(succeed_payload(access_token:, refresh_token:, exp:), status: :ok)
  rescue Jwt::Errors::ExpiredToken => e
    render_unauthorized(e)
  rescue Jwt::Errors::InvalidToken => e
    render_unauthorized(e)
  rescue Jwt::Errors::MissingToken => e
    render_unauthorized(e)
  rescue StandardError => e
    render_unauthorized(e)
  end

  private

  def succeed_payload(access_token:, refresh_token:, exp:)
    {
      title: Rack::Utils::HTTP_STATUS_CODES[200],
      data: {
        access_token:,
        refresh_token:,
        exp:
      }
    }
  end

  def authenticate_refresh_token
    @current_user, @decoded_token = Jwt::Authenticator.call(
      headers: request.headers,
      verify: false
    )
  rescue StandardError => e
    render_unauthorized(e)
  end
end
