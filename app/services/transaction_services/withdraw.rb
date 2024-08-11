module TransactionServices
  class Withdraw
    def initialize(wallet_id:, amount:)
      @wallet = Wallet.find(wallet_id)
      @amount = amount
    end

    def call
      ActiveRecord::Base.transaction do
        @wallet.transactions.withdraw.create!(amount: @amount)
        @wallet.balance -= @amount
        @wallet.save!
      end
    end
  end
end