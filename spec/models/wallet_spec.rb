require 'rails_helper'

RSpec.describe Wallet, type: :model do
  let(:user) { create(:user) }
  let(:wallet) { create(:wallet, :for_user, entity: user) }
  let(:team) { create(:team) }
  let(:team_wallet) { create(:wallet, entity: team) }

  describe 'Balance validation' do
    it 'has a default value of 0' do
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
      wallet.save
      expect(wallet).to be_valid
      expect(wallet.balance).to eq(0)
    end

    it 'cannot be less than 0' do
      wallet.balance = -100
      wallet.save
      expect(wallet).to_not be_valid
      expect(wallet.errors[:balance]).to include('must be greater than or equal to 0')
    end
  end

  describe 'Associations' do
    it 'belongs to an entity (polymorphic)' do
      expect(wallet.entity).to eq(user)
      expect(team_wallet.entity).to eq(team)
    end

    it 'has many transactions' do
      expect(wallet.transactions).to be_empty
      TransactionServices::Deposit.new(wallet_id: wallet.id, amount: 100).call
      expect(wallet.transactions.count).to eq(1)
    end

    it 'destroys associated transactions when the wallet is destroyed' do
      TransactionServices::Deposit.new(wallet_id: wallet.id, amount: 100).call
      expect { wallet.destroy }.to change { Transaction.count }.by(-1)
    end
  end

  describe 'Callbacks' do
    it 'sets default balance after initialization' do
      new_wallet = Wallet.new(entity: user)
      expect(new_wallet.balance).to eq(0)
    end
  end

  describe '#sum_transactions_balance' do
    it 'returns the correct balance after multiple transactions' do
      destination_wallet = create(:wallet, :for_team)
      expect(wallet.sum_transactions_balance).to eq(0)

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

  describe 'Edge cases' do
    it 'handles high precision balances correctly' do
      wallet.update(balance: BigDecimal('100.123456789'))
      expect(wallet.balance).to eq(BigDecimal('100.12'))
    end

    it 'does not allow transactions if balance is insufficient' do
      expect do
        TransactionServices::Withdraw.new(wallet_id: wallet.id, amount: 200).call
      end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Amount insufficient wallet balance')
      expect(wallet.reload.balance).to eq(0)
    end
  end
end
