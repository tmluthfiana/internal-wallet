require 'rails_helper'

RSpec.describe TransactionServices::Withdraw do
  let(:wallet) { create(:wallet, :for_user) }

  it 'create withdraw transaction' do
    wallet.update!(balance: 100)
    expect(wallet.balance).to eq(100)

    expect do
      TransactionServices::Withdraw.new(wallet_id: wallet.id, amount: 50).call
    end.to change { wallet.transactions.count }.by(1)
                                               .and change { wallet.reload.balance }.by(-50)
  end

  context 'failed transaction' do
    let(:wallet) { create(:wallet, :for_user) }

    before :each do
      wallet.update!(balance: 100)
      expect(wallet.balance).to eq(100)
    end

    it 'amount can not 0' do
      expect do
        TransactionServices::Withdraw.new(wallet_id: wallet.id, amount: 0).call
      end.to raise_error(ActiveRecord::RecordInvalid,
                         'Validation failed: Amount must be greater than 0')
    end

    it 'wallet id not found' do
      expect do
        TransactionServices::Withdraw.new(wallet_id: '123', amount: 100)
      end.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find Wallet with 'id'=123")
    end

    it 'balance not sufficient' do
      expect do
        TransactionServices::Withdraw.new(wallet_id: wallet.id, amount: 200).call
      end.to raise_error(ActiveRecord::RecordInvalid,
                         'Validation failed: Amount insufficient wallet balance')
    end
  end
end
