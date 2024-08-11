module RapidApi
  class LatestStockPrice
    BASE_URL = 'https://latest-stock-price.p.rapidapi.com'.freeze
    AUTH_KEY = Rails.application.credentials.dig(:rapid_api, :api_key)
    HEADERS = { headers: {
      'Content-Type' => 'application/octet-stream',
      'X-RapidAPI-Key' => AUTH_KEY
    } }.freeze

    class << self
      def price(indices)
        return if indices.nil?

        query = { query: { Indices: indices } }
        HTTParty.get("#{BASE_URL}/price", HEADERS.merge(query))
      end

      def price_all
        HTTParty.get("#{BASE_URL}/any", HEADERS)
      end
    end
  end
end