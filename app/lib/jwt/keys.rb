# class Jwt::Keys
#   def self.private_key
#     if Rails.env.test?
#       OpenSSL::PKey::RSA.new(File.read('spec/fixtures/keys/mock_jwtRS256.key')).read
#     else
#       OpenSSL::PKey::RSA.new Rails.root.join('keys/jwtRS256.key').read
#     end
#   end
# end

module Jwt::Keys
  module_function

  def private_key
    if Rails.env.test?
      OpenSSL::PKey::RSA.new(File.read('spec/fixtures/keys/mock_jwtRS256.key'))
    else
      OpenSSL::PKey::RSA.new(File.read(Rails.root.join('keys/jwtRS256.key')))
    end
  end

  def public_key
    OpenSSL::PKey::RSA.new(File.read(Rails.root.join('keys/jwtRS256.key.pub')))
  end
end