module TransactionServices
  class Withdraw
    def initialize(wallet_id:, amount:)
      @wallet = Wallet.find(wallet_id)
      @amount = BigDecimal(amount.to_s).round(2)
    end

    def call
      begin
        ActiveRecord::Base.transaction do
          @wallet.lock!

          if @wallet.balance < @amount
            raise ActiveRecord::RecordInvalid.new(@wallet), 'Validation failed: Amount insufficient wallet balance'
          end

          @wallet.transactions.withdraw.create!(amount: @amount)
          @wallet.balance -= @amount
          @wallet.save!
        end
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
        raise e
      end
    end
  end
end
