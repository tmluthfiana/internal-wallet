module Jwt::Issuer
  module_function

  def call(user)
    access_token, _jti, exp = Jwt::Encoder.call(user)
    refresh_token = user.refresh_tokens.create!

    [access_token, refresh_token.token, exp]
  end
end