require 'rails_helper'

RSpec.describe TransactionServices::Transfer do
  let(:source_wallet) { create(:wallet, :for_user) }
  let(:destination_wallet) { create(:wallet, :for_team) }

  it 'create transfer transaction' do
    source_wallet.update!(balance: 100)
    expect(source_wallet.balance).to eq(100)

    expect do
      TransactionServices::Transfer.new(
        source_wallet_id: source_wallet.id,
        destination_wallet_id: destination_wallet.id,
        amount: 50
      ).call
    end.to change { source_wallet.transactions.count }.by(1)
      .and change { source_wallet.reload.balance }.by(-50)
      .and change { destination_wallet.transactions.count }.by(1)
      .and change { destination_wallet.reload.balance }.by(50)
  end

  context 'failed transaction' do
    let(:source_wallet) { create(:wallet, :for_user) }
    let(:destination_wallet) { create(:wallet, :for_team) }

    before :each do
      source_wallet.update!(balance: 100)
      expect(source_wallet.balance).to eq(100)
    end

    it 'amount can not 0' do
      expect do
        TransactionServices::Transfer.new(
          source_wallet_id: source_wallet.id,
          destination_wallet_id: destination_wallet.id,
          amount: 0
        ).call
      end.to raise_error(ActiveRecord::RecordInvalid,
        'Validation failed: Amount must be greater than 0')
    end

    it 'source wallet id not found' do
      expect do
        TransactionServices::Transfer.new(
          source_wallet_id: '123',
          destination_wallet_id: destination_wallet.id,
          amount: 50
        ).call
      end.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find Wallet with 'id'=123")
    end

    it 'destination wallet id not found' do
      expect do
        TransactionServices::Transfer.new(
          source_wallet_id: source_wallet.id,
          destination_wallet_id: '123',
          amount: 50
        ).call
      end.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find Wallet with 'id'=123")
    end

    it 'balance not sufficient' do
      expect do
        TransactionServices::Transfer.new(
          source_wallet_id: source_wallet.id,
          destination_wallet_id: destination_wallet.id,
          amount: 150
        ).call
      end.to raise_error(ActiveRecord::RecordInvalid,
        'Validation failed: Amount insufficient wallet balance')
    end
  end
end
