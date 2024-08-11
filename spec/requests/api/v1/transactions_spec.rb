require 'rails_helper'

RSpec.describe 'Api::V1::Transactions', type: :request do
  let(:user) { create(:wallet, :for_user).entity }
  let(:jwt) { access_token }

  describe 'GET /api/v1/transactions' do
    it 'returns unauthorized' do
      get '/api/v1/transactions'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns ok' do
      get '/api/v1/transactions', headers: { 'Authorization' => "Bearer #{jwt}" }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /api/v1/transactions/deposit' do
    it 'returns unauthorized' do
      post '/api/v1/transactions/deposit'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns ok with valid params' do
      post '/api/v1/transactions/deposit',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { amount: 100 }

      expect(response).to have_http_status(:ok)
    end

    it 'returns unprocessable_entity missing params' do
      post '/api/v1/transactions/deposit',
           headers: { 'Authorization' => "Bearer #{jwt}" }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns bad_request with 0 amount' do
      post '/api/v1/transactions/deposit',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { amount: 0 }

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'POST /api/v1/transactions/withdraw' do
    before :each do
      user.wallet.update!(balance: 700)
    end

    it 'returns unauthorized' do
      post '/api/v1/transactions/withdraw'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a ok status' do
      post '/api/v1/transactions/withdraw',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { amount: 100 }

      expect(response).to have_http_status(:ok)
    end

    it 'returns unprocessable_entity with missing amount' do
      post '/api/v1/transactions/withdraw',
           headers: { 'Authorization' => "Bearer #{jwt}" }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns bad_request with 0 amount' do
      post '/api/v1/transactions/withdraw',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { amount: 0 }

      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad_request with unsufficient funds' do
      post '/api/v1/transactions/withdraw',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { amount: 1000 }

      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'POST /api/v1/transactions/transfer' do
    let(:destination_wallet) { create(:wallet, :for_user) }

    before :each do
      user.wallet.update!(balance: 700)
    end

    it 'returns unauthorized' do
      post '/api/v1/transactions/transfer'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a ok status' do
      post '/api/v1/transactions/transfer',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { destination_wallet_id: destination_wallet.id, amount: 100 }

      expect(response).to have_http_status(:ok)
    end

    it 'returns unprocessable_entity with missing amount' do
      post '/api/v1/transactions/transfer',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { destination_wallet_id: destination_wallet.id }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns unprocessable_entity with missing destination_wallet_id' do
      post '/api/v1/transactions/transfer',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { amount: 10 }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns bad_request with 0 amount' do
      post '/api/v1/transactions/transfer',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { destination_wallet_id: destination_wallet.id, amount: 0 }

      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad_request with unsufficient funds' do
      post '/api/v1/transactions/transfer',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { destination_wallet_id: destination_wallet.id, amount: 1000 }

      expect(response).to have_http_status(:bad_request)
    end

    it 'returns not_found with not exist wallet' do
      post '/api/v1/transactions/transfer',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { destination_wallet_id: 'abc', amount: 1000 }

      expect(response).to have_http_status(:not_found)
    end
  end
end
