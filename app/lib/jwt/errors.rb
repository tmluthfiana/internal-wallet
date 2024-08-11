module Jwt::Errors
  class Unauthorized < StandardError
    def initialize(msg = 'You are not authorized')
      super
    end
  end

  class MissingToken < StandardError
    def initialize(token:)
      msg = if token == 'access_token'
              'Missing access token'
            else
              'Missing refresh token'
            end
      super(msg)
    end
  end

  class InvalidToken < StandardError
    def initialize(token:)
      msg = if token == 'access_token'
              'Invalid access token'
            else
              'Invalid refresh token'
            end
      super(msg)
    end
  end

  class ExpiredToken < StandardError
    def initialize(token:)
      msg = if token == 'access_token'
              'Expired access token'
            else
              'Expired refresh token'
            end
      super(msg)
    end
  end
end