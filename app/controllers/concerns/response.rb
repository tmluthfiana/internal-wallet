module Response
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::ParameterMissing, with: :render_unprocessable_entity
  end

  def render_raw_response(response_hash, status: :ok)
    render json: response_hash, status: status
  end

  def render_unauthorized(exception)
    render_error_response(:unauthorized, exception.message)
  end

  def render_unprocessable_entity(exception)
    render_error_response(:unprocessable_entity, exception.message)
  end

  def render_not_found(exception)
    render_error_response(:not_found, exception.message)
  end

  def render_bad_request(exception)
    render_error_response(:bad_request, exception.message)
  end

  def render_success(detail)
    render_standard_response(:ok, detail)
  end

  def render_transactions(transactions)
    render_raw_response({
      status: '200',
      title: Rack::Utils::HTTP_STATUS_CODES[200],
      data: transactions.map(&:to_builder).map(&:attributes!)
    }, status: :ok)
  end

  private

  def render_error_response(status, detail)
    render_raw_response(
      build_response_hash(status, detail),
      status: status
    )
  end

  def render_standard_response(status, detail)
    render_raw_response(
      build_response_hash(status, detail),
      status: status
    )
  end

  def build_response_hash(status, detail)
    {
      title: Rack::Utils::HTTP_STATUS_CODES[Rack::Utils.status_code(status)],
      detail: detail
    }
  end
end
