class Api::V1::TransactionsController < ApplicationController
  before_action :set_wallet

  def index
    transactions = @wallet.transactions.order(id: :desc)
    render_transactions(transactions)
  end

  def deposit
    process_transaction(params[:amount]) do
      if TransactionServices::Deposit.new(wallet_id: @wallet.id, amount: params[:amount].to_i).call
        render_success('deposit succeed')
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    render_bad_request(e)
  end

  def withdraw
    process_transaction(params[:amount]) do
      if TransactionServices::Withdraw.new(wallet_id: @wallet.id, amount: params[:amount].to_i).call
        render_success('withdraw succeed')
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    render_bad_request(e)
  end

  def transfer
    raise ActionController::ParameterMissing, 'destination_wallet_id and amount are required' if params[:amount].blank? || params[:destination_wallet_id].blank?

    if TransactionServices::Transfer.new(
      source_wallet_id: @wallet.id,
      destination_wallet_id: params[:destination_wallet_id],
      amount: params[:amount].to_i
    ).call
      render_success('transfer succeed')
    end
  rescue ActiveRecord::RecordInvalid => e
    render_bad_request(e)
  end

  private

  def set_wallet
    @wallet = @current_user.wallet
  end

  def process_transaction(amount)
    raise ActionController::ParameterMissing, 'amount is required' if amount.blank?

    yield if block_given?
  end

  def render_transactions(transactions)
    render_raw_response({
      status: '200',
      title: Rack::Utils::HTTP_STATUS_CODES[200],
      data: transactions.map(&:to_builder).map(&:attributes!)
    }, status: :ok)
  end

  def render_success(detail)
    render_raw_response({
      title: Rack::Utils::HTTP_STATUS_CODES[200],
      detail: detail
    }, status: :ok)
  end
end
