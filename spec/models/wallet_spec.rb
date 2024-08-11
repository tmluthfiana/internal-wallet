# spec/models/wallet_spec.rb
require 'rails_helper'

RSpec.describe Wallet, type: :model do
  let(:user) { create(:user) }
  let(:wallet) { create(:wallet, :for_user, entity: user) }

  describe 'Balance validation' do
    it 'have default 0' do
      wallet = user.create_wallet

      expect(wallet).to be_valid
      expect(wallet.balance).to eq(0)
    end

    it 'balance can be greater than 0' do
      wallet.balance = 100
      wallet.save

      expect(wallet).to be_valid
      expect(wallet.balance).to eq(100)
    end

    it 'balance can be equal to 0' do
      wallet.save # factories already set to 0

      expect(wallet).to be_valid
      expect(wallet.balance).to eq(0)
    end

    it 'cannot be less than 0' do
      wallet.balance = -100
      wallet.save

      expect(wallet).to_not be_valid
    end
  end

  it 'should return correct balance' do
    destination_wallet = create(:wallet, :for_team)
    expect(wallet.sum_transactions_balance).to eq(0)
    wallet.save
    TransactionServices::Deposit.new(wallet_id: wallet.id, amount: 100).call
    expect(wallet.reload.sum_transactions_balance).to eq(100)

    TransactionServices::Withdraw.new(wallet_id: wallet.id, amount: 25).call
    expect(wallet.reload.sum_transactions_balance).to eq(75)

    TransactionServices::Transfer.new(
      source_wallet_id: wallet.id,
      destination_wallet_id: destination_wallet.id,
      amount: 25
    ).call
    expect(wallet.reload.sum_transactions_balance).to eq(50)
  end
end
