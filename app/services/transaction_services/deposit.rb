module TransactionServices
  class Deposit
    def initialize(wallet_id:, amount:)
      @wallet = Wallet.find(wallet_id)
      @amount = amount
    end

    def call
      ActiveRecord::Base.transaction do
        @wallet.transactions.deposit.create!(amount: @amount)
        @wallet.balance += @amount
        @wallet.save!
      end
    end
  end
end