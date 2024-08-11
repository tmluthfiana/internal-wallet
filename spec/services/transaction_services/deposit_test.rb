require 'rails_helper'

RSpec.describe TransactionServices::Deposit do
  let(:wallet) { create(:wallet, :for_user) }

  it 'create deposit transaction' do
    expect(wallet.balance).to eq(0)

    expect do
      TransactionServices::Deposit.new(wallet_id: wallet.id, amount: 100).call
    end.to change { wallet.transactions.count }.by(1)
                                               .and change { wallet.reload.balance }.by(100)
  end

  context 'failed transaction' do
    let(:wallet) { create(:wallet, :for_user) }
    it 'amount can not 0' do
      expect do
        TransactionServices::Deposit.new(wallet_id: wallet.id, amount: 0).call
      end.to raise_error(ActiveRecord::RecordInvalid,
                         'Validation failed: Amount must be greater than 0')
    end

    it 'wallet id not found' do
      expect do
        TransactionServices::Deposit.new(wallet_id: '123', amount: 100)
      end.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find Wallet with 'id'=123")
    end
  end
end
