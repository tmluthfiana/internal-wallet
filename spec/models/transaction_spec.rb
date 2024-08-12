# spec/models/transaction_spec.rb
require 'rails_helper'

RSpec.describe Transaction, type: :model do
  let(:wallet) { create(:wallet, :for_user) }
  let(:destination_wallet) { create(:wallet, :for_team) }

  describe 'Amount validation' do
    it 'is valid with an amount greater than 0' do
      expect(wallet.transactions.deposit.create(amount: 10)).to be_valid
    end

    it 'is not valid without an amount' do
      expect(wallet.transactions.deposit.create(amount: nil)).to_not be_valid
    end

    it 'is not valid with an amount of 0' do
      expect(wallet.transactions.deposit.create(amount: 0)).to_not be_valid
    end

    it 'is not valid with a negative amount' do
      expect(wallet.transactions.deposit.create(amount: -10)).to_not be_valid
    end
  end

  describe 'Transaction type' do
    it 'has a valid enum for transaction types' do
      expect(Transaction.transaction_types.keys).to include('deposit', 'withdraw', 'transfer')
    end
  end

  describe 'Wallet balance' do
    before :each do
      wallet.update!(balance: 100)
    end

    it 'returns true if the balance is sufficient for a withdraw transaction' do
      transaction = wallet.transactions.withdraw.new(amount: 50)
      expect(transaction.balance_sufficient?).to be true
    end

    it 'returns false if the balance is insufficient for a withdraw transaction' do
      transaction = wallet.transactions.withdraw.new(amount: 150)
      expect(transaction.balance_sufficient?).to be false
    end
  end

  describe 'Validations' do
    context 'when transaction type is withdraw or transfer' do
      it 'adds an error if the balance is insufficient' do
        wallet.update!(balance: 100)
        transaction = wallet.transactions.withdraw.new(amount: 150)
        transaction.valid?
        expect(transaction.errors[:amount]).to include('insufficient wallet balance')
      end
  
      it 'does not add an error if the balance is sufficient' do
        wallet.update!(balance: 100)
        transaction = wallet.transactions.withdraw.new(amount: 50)
        expect(transaction).to be_valid
      end
    end
  
    context 'when transaction type is deposit' do
      it 'does not add an error for insufficient balance' do
        transaction = wallet.transactions.deposit.new(amount: 50)
        expect(transaction).to be_valid
      end
    end
  end
  

  describe 'Store accessors' do
    it 'stores and retrieves source_wallet_id' do
      transaction = wallet.transactions.transfer.new(amount: 50, source_wallet_id: wallet.id, destination_wallet_id: destination_wallet.id)
      transaction.save
      expect(transaction.source_wallet_id).to eq(wallet.id)
    end

    it 'stores and retrieves destination_wallet_id' do
      transaction = wallet.transactions.transfer.new(amount: 50, source_wallet_id: wallet.id, destination_wallet_id: destination_wallet.id)
      transaction.save
      expect(transaction.destination_wallet_id).to eq(destination_wallet.id)
    end
  end

  describe '#to_builder' do
    it 'builds the correct JSON representation' do
      transaction = wallet.transactions.deposit.create(amount: 100)
      json = transaction.to_builder
      expect(json).to be_a(Hash)  # Ensure the output is a Hash
      expect(json['id']).to eq(transaction.id)
      expect(json['transaction_type']).to eq('deposit')
      expect(json['amount']).to eq(100)
    end
  end
end
