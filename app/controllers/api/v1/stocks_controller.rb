class Api::V1::StocksController < ApplicationController

  def price_all
    handle_request do
      response = RapidApi::LatestStockPrice.price_all
      render_raw_response(format_response(response), status: :ok)
    end
  end

  def price
    handle_request do
      raise ActionController::ParameterMissing, 'Indicies is required' if params[:Indices].blank?

      response = RapidApi::LatestStockPrice.price(params[:Indices])
      render_raw_response(format_response(response), status: :ok)
    end
  end

  private

  def handle_request
    yield
  rescue HTTParty::Error => e
    render_raw_response({
                          status: '503',
                          title: Rack::Utils::HTTP_STATUS_CODES[503],
                          error: 'Service is currently unavailable',
                          detail: e.message
                        }, status: :service_unavailable)
  end

  def format_response(response)
    {
      status: '200',
      title: Rack::Utils::HTTP_STATUS_CODES[200],
      data: JSON.parse(response.body)
    }
  end
end
