require 'bcrypt'

class User < ApplicationRecord
  include BCrypt

  attr_accessor :password
  before_save :encrypt_password

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :password, presence: true, length: { minimum: 6 }

  has_one :wallet, as: :entity, dependent: :destroy
  has_many :refresh_tokens

  def authenticate(password)
    if password_hash && BCrypt::Password.new(password_hash) == password
      self
    else
      nil
    end
  end

  private

  def encrypt_password
    return if password.blank?

    self.password_hash = BCrypt::Password.create(password)
  end
end
