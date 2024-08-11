require 'rails_helper'

RSpec.describe 'Api::V1::Stocks', type: :request do
  let(:user) { create(:user) }
  let(:jwt) { access_token }

  describe 'GET /price_all' do
    it 'returns unauthorized if no token is provided' do
      get '/api/v1/stocks/price_all'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a list of all stocks in JSON format' do
      get '/api/v1/stocks/price_all', headers: { 'Authorization' => "Bearer #{jwt}" }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(response.body).to be_present
    end

    it 'handles API errors gracefully' do
      allow(RapidApi::LatestStockPrice).to receive(:price_all).and_raise(HTTParty::Error.new("API Error"))
      get '/api/v1/stocks/price_all', headers: { 'Authorization' => "Bearer #{jwt}" }
      expect(response).to have_http_status(:service_unavailable)
      expect(response.parsed_body['error']).to eq('Service is currently unavailable')
      expect(response.parsed_body['detail']).to eq('API Error')
    end
  end

  describe 'GET /price' do
    it 'returns unauthorized if no token is provided' do
      get '/api/v1/stocks/price'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unprocessable_entity if Indices param is missing' do
      get '/api/v1/stocks/price', headers: { 'Authorization' => "Bearer #{jwt}" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body['detail']).to eq('param is missing or the value is empty: Indicies is required')
    end

    it 'returns unprocessable_entity if Indices param is empty' do
      get '/api/v1/stocks/price', headers: { 'Authorization' => "Bearer #{jwt}" }, params: { Indices: '' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body['detail']).to eq('param is missing or the value is empty: Indicies is required')
    end

    it 'returns a list of stock prices in JSON format for valid Indices' do
      get '/api/v1/stocks/price', headers: { 'Authorization' => "Bearer #{jwt}" },
                                  params: { Indices: 'NIFTY 50' }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(response.body).to be_present
    end

    it 'handles API errors gracefully' do
      allow(RapidApi::LatestStockPrice).to receive(:price).and_raise(HTTParty::Error.new("API Error"))
      get '/api/v1/stocks/price', headers: { 'Authorization' => "Bearer #{jwt}" },
                                  params: { Indices: 'NIFTY 50' }
      expect(response).to have_http_status(:service_unavailable)
      expect(response.parsed_body['error']).to eq('Service is currently unavailable')
      expect(response.parsed_body['detail']).to eq('API Error')
    end

    it 'returns an empty response if API returns an empty body' do
      allow(RapidApi::LatestStockPrice).to receive(:price).and_return(double(body: '{}'))
      get '/api/v1/stocks/price', headers: { 'Authorization' => "Bearer #{jwt}" },
                                  params: { Indices: 'NIFTY 50' }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('"data":{}')  
    end
  end
end
