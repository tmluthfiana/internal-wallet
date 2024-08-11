class Api::V1::StocksController < ApplicationController

  def price_all
    response = RapidApi::LatestStockPrice.price_all

    render_raw_response({
                          status: '200',
                          title: Rack::Utils::HTTP_STATUS_CODES[200],
                          data: JSON.parse(response.body)
                        }, status: :ok)
  end

  def price
    raise ActionController::ParameterMissing, 'Indicies is required' if params[:Indices].blank?

    response = RapidApi::LatestStockPrice.price(params[:Indices])
    render_raw_response({
                          status: '200',
                          title: Rack::Utils::HTTP_STATUS_CODES[200],
                          data: JSON.parse(response.body)
                        }, status: :ok)
  end
end
