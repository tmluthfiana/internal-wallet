require 'rails_helper'

RSpec.describe 'Api::V1::Authentications', type: :request do
  let(:user) { create(:user) }

  before do
    user = create(:user)
    access_token, _jti, _exp = Jwt::Encoder.call(user)
    allow(Jwt::Issuer).to receive(:call).and_return([access_token, "refresh_token", 3600])
    allow(Jwt::Refresher).to receive(:refresh!).and_return(["new_access_token", "new_refresh_token", 3600])
  end

  describe 'POST /api/v1/auth/sign_in' do
    it 'return ok status' do
      post '/api/v1/auth/sign_in', params: { email: user.email, password: '123456' }
      expect(response).to have_http_status(:ok)
    end

    it 'return unauthorized with non exist email' do
      post '/api/v1/auth/sign_in', params: { email: 'test@email.com', password: '123456' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'return unauthorized with wrong password' do
      post '/api/v1/auth/sign_in', params: { email: user.email, password: 'qwerty' }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/v1/auth/refresh_token' do
    it 'returns ok status' do
      user = create(:user)
      access_token, _jti, _exp = Jwt::Encoder.call(user)
      
      get '/api/v1/auth/refresh_token',
          headers: { 'Authorization' => "Bearer #{access_token}" },
          params: { refresh_token: 'refresh_token' }
  
      expect(response).to have_http_status(:ok)
    end

    it 'return unauthorized missing refresh token' do
      get '/api/v1/auth/refresh_token',
          headers: { 'Authorization' => "Bearer 'access_token'" }

      expect(response).to have_http_status(:unauthorized)
    end

    it 'return unauthorized with invalid refresh token' do
      get '/api/v1/auth/refresh_token',
          headers: { 'Authorization' => "Bearer 'access_token'" },
          params: { refresh_token: 'abc' }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end