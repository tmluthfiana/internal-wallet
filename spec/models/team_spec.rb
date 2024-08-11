require 'rails_helper'

RSpec.describe Team, type: :model do
  it 'is valid with valid attributes' do
    team = create(:team)
    expect(team).to be_valid
  end

  it 'requires the presence of name' do
    team = Team.create(name: nil)
    expect(team).to_not be_valid
  end
end
