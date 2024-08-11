class Api::V1::TransactionsController < ApplicationController
  before_action :set_wallet

  def index
    transactions = @wallet.transactions.order(id: :desc)
    render_raw_response({
                          status: '200',
                          title: Rack::Utils::HTTP_STATUS_CODES[200],
                          data: transactions.map { |t| t.to_builder.attributes! }
                        }, status: :ok)
  end

  def deposit
    raise ActionController::ParameterMissing, 'amount is required' if params[:amount].blank?

    if TransactionServices::Deposit.new(wallet_id: @wallet.id, amount: params[:amount].to_i).call
      render_raw_response({
                            title: Rack::Utils::HTTP_STATUS_CODES[200],
                            detail: 'deposit succeed'
                          }, status: :ok)
    end
  rescue ActiveRecord::RecordInvalid => e
    render_bad_request(e)
  end

  def withdraw
    raise ActionController::ParameterMissing, 'amount is required' if params[:amount].blank?

    if TransactionServices::Withdraw.new(wallet_id: @wallet.id, amount: params[:amount].to_i).call
      render_raw_response({
                            title: Rack::Utils::HTTP_STATUS_CODES[200],
                            detail: 'withdraw succeed'
                          }, status: :ok)
    end
  rescue ActiveRecord::RecordInvalid => e
    render_bad_request(e)
  end

  def transfer
    if params[:amount].blank? || params[:destination_wallet_id].blank?
      raise ActionController::ParameterMissing, 'destination_wallet_id and amount is required'
    end

    if TransactionServices::Transfer.new(
      source_wallet_id: @wallet.id,
      destination_wallet_id: params[:destination_wallet_id],
      amount: params[:amount].to_i
    ).call
      render_raw_response({
                            title: Rack::Utils::HTTP_STATUS_CODES[200],
                            detail: 'transfer succeed'
                          }, status: :ok)
    end
  rescue ActiveRecord::RecordInvalid => e
    render_bad_request(e)
  end

  private

  def set_wallet
    @wallet = @current_user.wallet
  end
end
