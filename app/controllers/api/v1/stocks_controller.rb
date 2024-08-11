class Api::V1::StocksController < ApplicationController
  include Response

  def price_all
    handle_request do
      response = RapidApi::LatestStockPrice.price_all
      render_success(format_response(response))
    end
  end

  def price
    handle_request do
      raise ActionController::ParameterMissing, 'Indices is required' if params[:Indices].blank?

      response = RapidApi::LatestStockPrice.price(params[:Indices])
      render_success(format_response(response))
    end
  end

  private

  def handle_request
    yield
  rescue HTTParty::Error => e
    render_error_response(:service_unavailable, 'Service is currently unavailable', e.message)
  end

  def format_response(response)
    {
      data: JSON.parse(response.body)
    }
  end
end
