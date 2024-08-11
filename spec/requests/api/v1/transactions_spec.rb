require 'rails_helper'

RSpec.describe 'Api::V1::Transactions', type: :request do
  let(:user) { create(:wallet, :for_user).entity }
  let(:jwt) { access_token }
  let(:valid_amount) { 100 }
  let(:invalid_amount) { 0 }
  let(:large_amount) { 1000 }
  let(:destination_wallet) { create(:wallet, :for_user) }
  let(:non_existent_wallet_id) { 'nonexistent_wallet_id' }

  before do
    user.wallet.update!(balance: 700)
  end

  describe 'GET /api/v1/transactions' do
    it 'returns unauthorized without token' do
      get '/api/v1/transactions'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns ok with valid token' do
      get '/api/v1/transactions', headers: { 'Authorization' => "Bearer #{jwt}" }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /api/v1/transactions/deposit' do
    it 'returns unauthorized without token' do
      post '/api/v1/transactions/deposit'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns ok with valid params' do
      post '/api/v1/transactions/deposit',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { amount: valid_amount }
      expect(response).to have_http_status(:ok)
    end

    it 'returns unprocessable_entity with missing amount' do
      post '/api/v1/transactions/deposit',
           headers: { 'Authorization' => "Bearer #{jwt}" }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns bad_request with 0 amount' do
      post '/api/v1/transactions/deposit',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { amount: invalid_amount }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad_request with negative amount' do
      post '/api/v1/transactions/deposit',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { amount: -50 }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'POST /api/v1/transactions/withdraw' do
    it 'returns unauthorized without token' do
      post '/api/v1/transactions/withdraw'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns ok with valid params' do
      post '/api/v1/transactions/withdraw',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { amount: valid_amount }
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
           params: { amount: invalid_amount }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad_request with insufficient funds' do
      post '/api/v1/transactions/withdraw',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { amount: large_amount }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad_request with negative amount' do
      post '/api/v1/transactions/withdraw',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { amount: -50 }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'POST /api/v1/transactions/transfer' do
    it 'returns unauthorized without token' do
      post '/api/v1/transactions/transfer'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns ok with valid params' do
      post '/api/v1/transactions/transfer',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { destination_wallet_id: destination_wallet.id, amount: valid_amount }
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
           params: { amount: valid_amount }
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'returns bad_request with 0 amount' do
      post '/api/v1/transactions/transfer',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { destination_wallet_id: destination_wallet.id, amount: invalid_amount }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns bad_request with insufficient funds' do
      post '/api/v1/transactions/transfer',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { destination_wallet_id: destination_wallet.id, amount: large_amount }
      expect(response).to have_http_status(:bad_request)
    end

    it 'returns not_found with non-existent wallet' do
      post '/api/v1/transactions/transfer',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { destination_wallet_id: non_existent_wallet_id, amount: valid_amount }
      expect(response).to have_http_status(:not_found)
    end

    it 'returns bad_request with negative amount' do
      post '/api/v1/transactions/transfer',
           headers: { 'Authorization' => "Bearer #{jwt}" },
           params: { destination_wallet_id: destination_wallet.id, amount: -50 }
      expect(response).to have_http_status(:bad_request)
    end
  end
end
