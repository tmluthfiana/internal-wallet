module TransactionServices
  class Transfer
    def initialize(source_wallet_id:, destination_wallet_id:, amount:)
      @source_wallet = Wallet.find(source_wallet_id)
      @destination_wallet = Wallet.find(destination_wallet_id)
      @amount = amount
    end

    def call
      ActiveRecord::Base.transaction do
        create_source_transaction!
        create_destination_transaction!
      end
    end

    def create_source_transaction!
      @source_wallet.transactions.transfer.create!(
        amount: @amount,
        destination_wallet_id: @destination_wallet.id
      )
      @source_wallet.balance -= @amount
      @source_wallet.save!
    end

    def create_destination_transaction!
      @destination_wallet.transactions.transfer.create(
        amount: @amount,
        source_wallet_id: @source_wallet.id
      )
      @destination_wallet.balance += @amount
      @destination_wallet.save!
    end
  end
end