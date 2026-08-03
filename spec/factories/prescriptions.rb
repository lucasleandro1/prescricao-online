FactoryBot.define do
  factory :prescription do
    sequence(:title) { |n| "#{Faker::Lorem.words(number: 3).join(" ")} #{n}" }
    content  { "<strong>USO ORAL</strong>\n1 - #{Faker::Lorem.sentence}" }
    category { Faker::Lorem.word.capitalize }
    position { nil }
  end
end
