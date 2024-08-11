FactoryBot.define do
  factory :wallet do
    trait :for_user do
      association :entity, factory: :user
      balance { 0 }
    end

    trait :for_team do
      association :entity, factory: :team
      balance { 0 }
    end
  end
end