FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    sequence(:username) { |n| "user#{n}" }
    password { "Password1!" }

    after(:build) do |user, evaluator|
      # Adds a magic method that we can use in the `sign_in` without having to pass the password.
      user.define_singleton_method(:test_password) { evaluator.password }
    end
  end
end
