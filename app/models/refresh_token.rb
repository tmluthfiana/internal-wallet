class RefreshToken < ApplicationRecord
  attr_accessor :token

  belongs_to :user

  before_create :set_crypted_token

  def self.search_by_token(token)
    crypted_token = Digest::SHA256.hexdigest(token)
    RefreshToken.find_by(crypted_token: crypted_token)
  end

  def expired?
    Time.current > created_at + 1.day
  end

  private

  def set_crypted_token
    self.token = SecureRandom.hex
    self.crypted_token = Digest::SHA256.hexdigest(self.token)
  end  
end

