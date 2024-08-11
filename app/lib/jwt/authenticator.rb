module Jwt::Authenticator
  module_function

  def call(headers:, verify: true)
    token = Jwt::Authenticator.authenticate_header(
      headers
    )
    raise Jwt::Errors::MissingToken.new(token: 'access_token') if token.blank?

    decoded_token = Jwt::Decoder.decode!(token, verify:)
    user = Jwt::Authenticator.authenticate_user_from_token(decoded_token)

    raise Jwt::Errors::Unauthorized if user.blank?

    [user, decoded_token]
  end

  def authenticate_header(headers)
    token = headers['Authorization']&.split('Bearer ')&.last
    raise Jwt::Errors::InvalidToken.new(token: 'access_token') if token.blank? || token.split('.').size != 3
    token
  end

  def authenticate_user_from_token(decoded_token)
    unless decoded_token[:jti].present? && decoded_token[:user_id].present?
      raise Jwt::Errors::InvalidToken.new(token: 'access_token')
    end

    User.find(decoded_token[:user_id])
  end
end