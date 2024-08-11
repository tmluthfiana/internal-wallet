require 'rails_helper'

RSpec.describe User, type: :model do
  it 'should create user' do
    user = create(:user)
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
end
