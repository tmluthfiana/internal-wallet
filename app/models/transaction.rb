class Transaction < ApplicationRecord
  belongs_to :wallet

  enum transaction_type: {
    deposit: 'deposit',
    withdraw: 'withdraw',
    transfer: 'transfer'
  }

  store_accessor :details, :source_wallet_id
  store_accessor :details, :destination_wallet_id

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validate :sufficient_balance

  def to_builder
    Jbuilder.new do |builder|
      builder.id id
      builder.transaction_type transaction_type
      builder.amount amount
    end.attributes!
  end

  def balance_sufficient?
    amount <= wallet.balance
  end

  private

  def sufficient_balance
    return if transaction_type == 'deposit'

    errors.add(:amount, 'insufficient wallet balance') unless balance_sufficient?
  end
end
