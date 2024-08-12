require 'rails_helper'

RSpec.describe TransactionServices::Withdraw do
  let(:wallet) { create(:wallet, :for_user) }

  before :each do
    wallet.update!(balance: BigDecimal(100.to_s).round(2))
    expect(wallet.balance).to eq(BigDecimal(100.to_s).round(2))
  end

  describe '#call' do
    context 'successful transaction' do
      it 'creates a withdraw transaction and updates the wallet balance' do
        expect do
          TransactionServices::Withdraw.new(wallet_id: wallet.id, amount: 50).call
        end.to change { wallet.transactions.count }.by(1)
                                                 .and change { wallet.reload.balance }.by(BigDecimal('-50.0'))
      end

      it 'allows withdrawing the entire balance' do
        expect do
          TransactionServices::Withdraw.new(wallet_id: wallet.id, amount: 100).call
        end.to change { wallet.transactions.count }.by(1)
                                                   .and change { wallet.reload.balance }.by(BigDecimal('-100.0'))
      end
    end

    context 'failed transaction' do
      it 'does not allow withdrawing 0 amount' do
        expect do
          TransactionServices::Withdraw.new(wallet_id: wallet.id, amount: 0).call
        end.to raise_error(ActiveRecord::RecordInvalid,
                           'Validation failed: Amount must be greater than 0')
      end

      it 'raises an error if wallet id is not found' do
        expect do
          TransactionServices::Withdraw.new(wallet_id: '123', amount: 50).call
        end.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find Wallet with 'id'=123")
      end

      it 'raises an error if balance is insufficient' do
        expect do
          TransactionServices::Withdraw.new(wallet_id: wallet.id, amount: 200).call
        end.to raise_error(ActiveRecord::RecordInvalid,
                           'Validation failed: Amount insufficient wallet balance')
      end

      it 'does not create a transaction if an error occurs' do
        expect do
          begin
            TransactionServices::Withdraw.new(wallet_id: wallet.id, amount: 200).call
          rescue ActiveRecord::RecordInvalid
            nil
          end
        end.not_to change { wallet.transactions.count }

        expect(wallet.reload.balance).to eq(BigDecimal('100.0'))
      end
    end

    context 'concurrent transactions' do
      it 'raises an error if the total withdrawal amount exceeds the balance' do
        threads = []
        errors = []

        6.times do
          threads << Thread.new do
            begin
              TransactionServices::Withdraw.new(wallet_id: wallet.id, amount: BigDecimal(20.to_s)).call
            rescue ActiveRecord::RecordInvalid => e
              errors << e
            end
          end
        end

        threads.each(&:join)

        wallet.reload

        expect(wallet.transactions.count).to be <= 5
        expect(errors.size).to eq(1)
        expect(wallet.balance).to be >= BigDecimal(0.to_s)
      end
    end

    context 'edge cases' do
      it 'handles high precision amounts' do
        expect do
          TransactionServices::Withdraw.new(wallet_id: wallet.id, amount: BigDecimal(50.12345.to_s)).call
        end.to change { wallet.transactions.count }.by(1)
                                                  .and change { wallet.reload.balance }.by(BigDecimal(-50.12.to_s))
      end
    end
  end
end
