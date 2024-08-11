require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:wallet) { create(:wallet, :for_user) }

  describe 'Amount validation' do
    it 'can greater than 0' do
      expect(wallet.transactions.deposit.create(amount: 10)).to be_valid
    end

    it 'should have presence of amount' do
      expect(wallet.transactions.deposit.create(amount: nil)).to_not be_valid
    end

    it 'can not be 0' do
      expect(wallet.transactions.deposit.create(amount: 0)).to_not be_valid
    end

    it 'can not less than 0' do
      expect(wallet.transactions.deposit.create(amount: -10)).to_not be_valid
    end
  end

  describe 'wallet balance' do
    before :each do
      wallet.update!(balance: 100)
    end

    it 'should return true' do
      transaction = wallet.transactions.withdraw.new(amount: 50)
      expect(transaction.balance_sufficient?).to be true
    end

    it 'should return false' do
      transaction = wallet.transactions.withdraw.new(amount: 150)
      expect(transaction.balance_sufficient?).to be false
    end
  end
end
