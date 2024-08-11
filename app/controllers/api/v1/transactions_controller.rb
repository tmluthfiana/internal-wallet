class Api::V1::TransactionsController < ApplicationController
  before_action :set_wallet

  def index
    transactions = @wallet.transactions.order(id: :desc)
    render_transactions(transactions)
  end

  def deposit
    raise ActionController::ParameterMissing, 'amount is required' if params[:amount].blank?
  
    amount = params[:amount].to_i
  
    if amount <= 0
      return render_raw_response({
                                   title: Rack::Utils::HTTP_STATUS_CODES[400],
                                   detail: 'Amount must be positive'
                                 }, status: :bad_request)
    end
  
    if TransactionServices::Deposit.new(wallet_id: @wallet.id, amount: amount).call
      render_raw_response({
                            title: Rack::Utils::HTTP_STATUS_CODES[200],
                            detail: 'Deposit succeeded'
                          }, status: :ok)
    end
  rescue ActiveRecord::RecordInvalid => e
    render_bad_request(e)
  rescue ArgumentError => e
    render_raw_response({
                          title: Rack::Utils::HTTP_STATUS_CODES[400],
                          detail: e.message
                        }, status: :bad_request)
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
end
