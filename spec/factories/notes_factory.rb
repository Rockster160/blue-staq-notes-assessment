FactoryBot.define do
  factory :note do
    title { "Awesome note" }
    body { "Awesome body" }

    association :team
    association :author, factory: :user
  end
end
