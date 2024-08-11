class Team < ApplicationRecord
  has_one :wallet, as: :entity, dependent: :destroy

  validates :name, presence: true
end
