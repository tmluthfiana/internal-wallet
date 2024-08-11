module TransactionServices
  class Deposit
    def initialize(wallet_id:, amount:)
      @wallet = Wallet.find_by(id: wallet_id)
      @amount = amount
      validate!
    end

    def call
      ActiveRecord::Base.transaction do
        create_transaction
        update_wallet_balance
      end
    end

    private

    def validate!
      raise ActiveRecord::RecordNotFound, 'Wallet not found' if @wallet.nil?
      raise ArgumentError, 'Amount must be positive' if @amount <= 0
    end

    def create_transaction
      @wallet.transactions.create!(amount: @amount, transaction_type: 'deposit')
    end

    def update_wallet_balance
      @wallet.increment!(:balance, @amount)
    end
  end
end
