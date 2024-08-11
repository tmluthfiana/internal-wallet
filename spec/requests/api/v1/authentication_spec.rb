require 'rails_helper'

RSpec.describe 'Api::V1::Authentications', type: :request do
  let(:user) { create(:user) }
  let(:access_token) { 'valid_access_token' }
  let(:refresh_token) { 'valid_refresh_token' }
  let(:new_access_token) { 'new_valid_access_token' }
  let(:new_refresh_token) { 'new_valid_refresh_token' }

  before do
    allow(Jwt::Issuer).to receive(:call).and_return([access_token, refresh_token, 3600])
    allow(Jwt::Refresher).to receive(:refresh!).and_return([new_access_token, new_refresh_token, 3600])
    allow(Jwt::Encoder).to receive(:call).and_return([access_token, refresh_token, 3600])
    allow(Jwt::Authenticator).to receive(:call).and_return([user, {}])
  end

  describe 'POST /api/v1/auth/sign_in' do
    it 'returns ok status with valid credentials' do
      post '/api/v1/auth/sign_in', params: { email: user.email, password: '123456' }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data']['access_token']).to eq(access_token)
      expect(response.parsed_body['data']['refresh_token']).to eq(refresh_token)
    end

    it 'returns unauthorized with non-existent email' do
      post '/api/v1/auth/sign_in', params: { email: 'nonexistent@email.com', password: '123456' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unauthorized with incorrect password' do
      post '/api/v1/auth/sign_in', params: { email: user.email, password: 'wrongpassword' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unauthorized with missing email' do
      post '/api/v1/auth/sign_in', params: { password: '123456' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unauthorized with missing password' do
      post '/api/v1/auth/sign_in', params: { email: user.email }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/auth/refresh_token' do
    it 'returns ok status with valid refresh token' do
      get '/api/v1/auth/refresh_token',
          headers: { 'Authorization' => "Bearer #{access_token}" },
          params: { refresh_token: refresh_token }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data']['access_token']).to eq(new_access_token)
      expect(response.parsed_body['data']['refresh_token']).to eq(new_refresh_token)
    end

    it 'returns unauthorized with missing refresh token' do
      get '/api/v1/auth/refresh_token',
          headers: { 'Authorization' => "Bearer #{access_token}" }

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['error']).to include('Missing refresh token')
    end

    it 'returns unauthorized with invalid refresh token' do
      allow(Jwt::Refresher).to receive(:refresh!).and_raise(StandardError.new('Invalid refresh token'))

      get '/api/v1/auth/refresh_token',
          headers: { 'Authorization' => "Bearer #{access_token}" },
          params: { refresh_token: 'invalid_refresh_token' }

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['error']).to include('Invalid refresh token')
    end

    it 'returns unauthorized with invalid access token' do
      allow(Jwt::Authenticator).to receive(:call).and_raise(StandardError.new('Invalid access token'))

      get '/api/v1/auth/refresh_token',
          headers: { 'Authorization' => "Bearer invalid_access_token" },
          params: { refresh_token: refresh_token }

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['error']).to include('Invalid access token')
    end

    it 'returns unauthorized with expired refresh token' do
      allow(Jwt::Refresher).to receive(:refresh!).and_raise(Jwt::Errors::ExpiredToken.new(token: 'refresh'))

      get '/api/v1/auth/refresh_token',
          headers: { 'Authorization' => "Bearer #{access_token}" },
          params: { refresh_token: refresh_token }

      expect(response).to have_http_status(:unauthorized)
      expect(response.parsed_body['error']).to include('Expired refresh token')
    end
  end
end
