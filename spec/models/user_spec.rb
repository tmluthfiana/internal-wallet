require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }
  let!(:wallet) { create(:wallet, entity: user) }  # Create a wallet for the user
  let!(:refresh_token) { create(:refresh_token, user: user) }  # Create a refresh token for the user

  it 'should create user' do
    expect(user).to be_valid
  end

  context 'validations' do
    it 'requires the presence of email' do
      user = User.new(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: nil,
        password: '123456'
      )
      expect(user).to_not be_valid
    end

    it 'requires valid email' do
      user = User.new(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: 'test@',
        password: '123456'
      )
      expect(user).to_not be_valid
    end

    it 'requires unique email' do
      user = create(:user)
      new_user = User.new(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        email: user.email,
        password: '123456'
      )
      expect(new_user).to_not be_valid
    end

    it 'requires the presence of first_name' do
      user = User.new(
        first_name: nil,
        last_name: Faker::Name.last_name,
        email: Faker::Internet.email,
        password: '123456'
      )
      expect(user).to_not be_valid
    end

    it 'requires the presence of last_name' do
      user = User.new(
        first_name: Faker::Name.first_name,
        last_name: nil,
        email: Faker::Internet.email,
        password: '123456'
      )
      expect(user).to_not be_valid
    end

    it 'requires the presence of password' do
      user = User.new(email: 'test@email.com', password: nil)
      expect(user).to_not be_valid
    end

    it 'requires password minimum length' do
      user = User.new(email: 'test@email.com', password: '123')
      expect(user).to_not be_valid
    end
  end

  describe 'password encryption' do
    it 'encrypts password before saving' do
      user = User.new(
        first_name: 'John',
        last_name: 'Doe',
        email: 'john.doe@example.com',
        password: 'password123'
      )
      user.save
      expect(user.password_hash).to be_present
      expect(BCrypt::Password.new(user.password_hash)).to eq('password123')
    end

    it 'does not set password_hash if password is blank' do
      user = User.new(
        first_name: 'Jane',
        last_name: 'Doe',
        email: 'jane.doe@example.com',
        password: nil
      )
      user.save
      expect(user.password_hash).to be_nil
    end
  end

  describe 'authentication' do
    it 'returns the user when password is correct' do
      authenticated_user = user.authenticate(user.password)
      expect(authenticated_user).to eq(user)
    end

    it 'returns nil when password is incorrect' do
      expect(user.authenticate('wrongpassword')).to be_nil
    end
  end

  describe 'associations' do
    it 'has one wallet' do
      expect(user.wallet).to eq(wallet)
    end
  
    it 'has many refresh_tokens' do
      expect(user.refresh_tokens).to include(refresh_token)
    end
  end
end
