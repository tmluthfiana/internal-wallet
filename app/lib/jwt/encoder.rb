module Jwt::Encoder
  module_function

  def call(user)
    jti = SecureRandom.hex
    exp = Jwt::Encoder.token_expiry
    access_token = JWT.encode(
      {
        jti:,
        iat: Jwt::Encoder.token_issued_at.to_i,
        exp:,
        # TODO: remove this if already implement whitelist get user id from whitelist
        user_id: user.id
      },
      Jwt::Keys.private_key,
      'RS256'
    )

    [access_token, jti, exp]
  end

  def token_expiry
    (Jwt::Encoder.token_issued_at + 1.hour).to_i
  end

  def token_issued_at
    Time.zone.now
  end
end