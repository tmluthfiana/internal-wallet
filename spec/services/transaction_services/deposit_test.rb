require 'rails_helper'

RSpec.describe TransactionServices::Deposit do
  let(:wallet) { create(:wallet, :for_user) }

  it 'creates a deposit transaction' do
    expect(wallet.balance).to eq(0)

    expect do
      TransactionServices::Deposit.new(wallet_id: wallet.id, amount: 100).call
    end.to change { wallet.transactions.count }.by(1)
                                               .and change { wallet.reload.balance }.by(100)
  end

  context 'failed transaction' do
    let(:wallet) { create(:wallet, :for_user) }

    it 'amount cannot be zero' do
      expect do
        TransactionServices::Deposit.new(wallet_id: wallet.id, amount: 0).call
      end.to raise_error(ArgumentError, 'Amount must be positive')
    end

    it 'wallet id not found' do
      expect do
        TransactionServices::Deposit.new(wallet_id: '123', amount: 100).call
      end.to raise_error(ActiveRecord::RecordNotFound, 'Wallet not found')
    end

    it 'amount cannot be negative' do
      expect do
        TransactionServices::Deposit.new(wallet_id: wallet.id, amount: -100).call
      end.to raise_error(ArgumentError, 'Amount must be positive')
    end

    it 'creates no transaction if wallet is not found' do
      expect do
        expect do
          TransactionServices::Deposit.new(wallet_id: '123', amount: 100).call
        end.to raise_error(ActiveRecord::RecordNotFound, 'Wallet not found')
      end.not_to change { Transaction.count }
    end

    it 'does not update wallet balance if transaction creation fails' do
      allow_any_instance_of(Wallet).to receive(:transactions).and_raise(ActiveRecord::RecordInvalid.new(Wallet.new))

      expect do
        expect do
          TransactionServices::Deposit.new(wallet_id: wallet.id, amount: 100).call
        end.to raise_error(ActiveRecord::RecordInvalid)
      end.not_to change { wallet.reload.balance }
    end

    it 'does not update wallet balance if balance update fails' do
      allow_any_instance_of(Wallet).to receive(:increment!).and_raise(ActiveRecord::RecordInvalid.new(Wallet.new))

      expect do
        expect do
          TransactionServices::Deposit.new(wallet_id: wallet.id, amount: 100).call
        end.to raise_error(ActiveRecord::RecordInvalid)
      end.not_to change { wallet.reload.balance }
    end

    it 'handles edge case of very small amount' do
      expect(wallet.balance).to eq(0)

      expect do
        TransactionServices::Deposit.new(wallet_id: wallet.id, amount: 0.01).call
      end.to change { wallet.transactions.count }.by(1)

      wallet.reload
      expect(wallet.balance).to eq(0.01)
    end
  end
end
