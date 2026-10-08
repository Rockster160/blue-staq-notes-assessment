FactoryBot.define do
  factory :team do
    sequence(:name) { |n| "Team #{n}" }

    owner_id { create(:user).id }
  end
end
