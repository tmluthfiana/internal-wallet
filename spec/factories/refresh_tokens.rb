FactoryBot.define do
  factory :refresh_token do
    user
    token { SecureRandom.hex }
    crypted_token { Digest::SHA256.hexdigest(token) }
  end
end
