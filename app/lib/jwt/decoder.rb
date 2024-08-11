module Jwt
  module Decoder
    module_function

    def decode!(access_token, verify: true)
      decoded = JWT.decode(access_token, Jwt::Keys.private_key, verify, { algorithm: 'RS256', verify_iat: true })[0]
      raise Jwt::Errors::InvalidToken.new(token: 'access_token') if decoded.blank?

      decoded.symbolize_keys
    end
  end
end
