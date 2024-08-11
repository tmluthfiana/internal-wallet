class Wallet < ApplicationRecord
  belongs_to :entity, polymorphic: true

  has_many :transactions, dependent: :destroy

  validates :balance, numericality: { greater_than_or_equal_to: 0 }

  after_initialize :set_default_balance, if: -> { new_record? }

  def sum_transactions_balance
    transactions.inject(0) do |sum, t|
      if t.deposit? || (t.transfer? && t.source_wallet_id.present?)
        sum + t.amount
      else
        sum - t.amount
      end
    end
  end

  private

  def set_default_balance
    self.balance ||= 0
  end
end
