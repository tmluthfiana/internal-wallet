require 'rails_helper'

RSpec.describe RefreshToken, type: :model do
  let(:user) { create(:user) }
  let(:refresh_token) { create(:refresh_token, user: user) }

  context 'associations' do
    it 'belongs to a user' do
      expect(refresh_token.user).to eq(user)
    end
  end

  context 'validations' do
    it 'should create a valid refresh token' do
      expect(refresh_token).to be_valid
    end

    it 'should have a crypted_token after creation' do
      expect(refresh_token.crypted_token).not_to be_nil
    end

    it 'should not be valid without a user' do
      token = RefreshToken.new
      expect(token).to_not be_valid
    end
  end

  context 'methods' do
    describe '#set_crypted_token' do
      it 'sets the crypted_token before creating' do
        token = SecureRandom.hex
        refresh_token = RefreshToken.new(user: user, token: token)
        refresh_token.send(:set_crypted_token)
        expect(refresh_token.crypted_token).to eq(Digest::SHA256.hexdigest(refresh_token.token))
      end

      it 'does not overwrite crypted_token if token is not set' do
        refresh_token = RefreshToken.create!(user: user)
        original_crypted_token = refresh_token.crypted_token
        refresh_token.send(:set_crypted_token)
        expect(refresh_token.crypted_token).to eq(original_crypted_token)
      end
    end

    describe '.search_by_token' do
      it 'finds a refresh token by its token' do
        found_token = RefreshToken.search_by_token(refresh_token.token)
        expect(found_token).to eq(refresh_token)
      end

      it 'returns nil for a non-existent token' do
        expect(RefreshToken.search_by_token('non_existent_token')).to be_nil
      end

      it 'finds token using partial token' do
        partial_token = refresh_token.token[0..7]  # Partial token for testing
        crypted_partial = Digest::SHA256.hexdigest(partial_token)
        create(:refresh_token, crypted_token: crypted_partial, user: user)
        expect(RefreshToken.search_by_token(partial_token)).to be_nil  # Should return nil as it's not exact match
      end
    end

    describe '#expired?' do
      it 'returns true if the token is expired' do
        old_token = RefreshToken.create!(user: user, created_at: 2.days.ago)
        expect(old_token).to be_expired
      end

      it 'returns false if the token is not expired' do
        recent_token = RefreshToken.create!(user: user)
        expect(recent_token).not_to be_expired
      end

      it 'returns false if the token is exactly 1 day old' do
        token_1_day_old = RefreshToken.create!(user: user, created_at: 1.day.ago)
        expect(token_1_day_old).not_to be_expired
      end      
    end
  end
end
