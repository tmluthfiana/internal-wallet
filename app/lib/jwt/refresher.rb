module Jwt
  module Refresher
    module_function

    def refresh!(refresh_token, decoded_token, user)
      raise Jwt::Errors::MissingToken, token: 'refresh' unless refresh_token.present? || decoded_token.nil?

      existing_refresh_token = user.refresh_tokens.search_by_token(refresh_token)
      raise Jwt::Errors::InvalidToken.new(token: 'refresh') if existing_refresh_token.blank?
      raise Jwt::Errors::ExpiredToken, new(token: 'refresh') if existing_refresh_token.expired?

      existing_refresh_token.destroy!
      new_access_token, new_refresh_token, exp = Jwt::Issuer.call(user)

      [new_access_token, new_refresh_token, exp]
    end
  end
end
