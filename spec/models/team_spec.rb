require 'rails_helper'

RSpec.describe Team, type: :model do
  let(:team) { create(:team) }

  context 'validations' do
    it 'is valid with valid attributes' do
      expect(team).to be_valid
    end

    it 'requires the presence of a name' do
      team.name = nil
      expect(team).to_not be_valid
      expect(team.errors[:name]).to include("can't be blank")
    end
  end

  context 'associations' do
    it 'has one wallet' do
      expect(team.build_wallet).to be_a_new(Wallet)
    end

    it 'destroys the associated wallet when the team is destroyed' do
      team.create_wallet(balance: 100)
      expect { team.destroy }.to change { Wallet.count }.by(-1)
    end

    it 'does not delete the wallet if team has no wallet associated' do
      expect { team.destroy }.not_to change { Wallet.count }
    end
  end

  context 'database columns' do
    it 'has a name column of type string' do
      expect(Team.columns_hash['name'].type).to eq(:string)
    end

    it 'has timestamps columns' do
      expect(Team.columns_hash['created_at'].type).to eq(:datetime)
      expect(Team.columns_hash['updated_at'].type).to eq(:datetime)
    end
  end
end
