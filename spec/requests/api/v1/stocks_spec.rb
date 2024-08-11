require 'rails_helper'

RSpec.describe 'Api::V1::Stocks', type: :request do
  let(:user) { create(:user) }
  let(:jwt) { access_token }

  describe 'GET /price_all' do
    it 'returns unauthorized' do
      get '/api/v1/stocks/price_all'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns a list of all stocks in JSON format' do
      get '/api/v1/stocks/price_all', headers: { 'Authorization' => "Bearer #{jwt}" }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end
  end

  describe 'GET /price' do
    it 'returns unauthorized' do
      get '/api/v1/stocks/price'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns unprocessable_entity' do
      get '/api/v1/stocks/price', headers: { 'Authorization' => "Bearer #{jwt}" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body['detail']).to eq('param is missing or the value is empty: Indicies is required')
    end

    it 'returns a list of stock price in JSON format' do
      # TODO: better use VCR casseete so it won't request to the rapid api to make it faster
      get '/api/v1/stocks/price', headers: { 'Authorization' => "Bearer #{jwt}" },
                                  params: { Indices: 'NIFTY 50' }
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq('application/json; charset=utf-8')
    end
  end
end
