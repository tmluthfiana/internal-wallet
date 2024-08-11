module Response
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionController::ParameterMissing, with: :render_unprocessable_entity
  end

  def render_raw_response(payload, status:)
    payload.deep_stringify_keys!
    payload = payload.slice('title', 'detail', 'data')
    render json: Oj.dump(payload.compact), status:
  end

  def render_unauthorized(exception)
    render_raw_response(
      {
        title: Rack::Utils::HTTP_STATUS_CODES[401],
        detail: exception.message
      }, status: :unauthorized
    )
  end

  def render_unprocessable_entity(exception)
    render_raw_response(
      {
        title: Rack::Utils::HTTP_STATUS_CODES[422],
        detail: exception.message
      }, status: :unprocessable_entity
    )
  end

  def render_not_found(exception)
    render_raw_response(
      {
        title: Rack::Utils::HTTP_STATUS_CODES[404],
        detail: exception.message
      }, status: :not_found
    )
  end

  def render_bad_request(exception)
    render_raw_response(
      {
        title: Rack::Utils::HTTP_STATUS_CODES[400],
        detail: exception.message
      }, status: :bad_request
    )
  end
end