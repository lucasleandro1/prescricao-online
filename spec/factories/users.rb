FactoryBot.define do
  factory :user do
    name  { Faker::Name.name }
    email { Faker::Internet.unique.email }
    password { "Password@123" }
    password_confirmation { "Password@123" }
    role { "user" }

    trait :admin do
      role { "admin" }
    end
  end
end
