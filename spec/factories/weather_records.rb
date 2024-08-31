FactoryBot.define do
  factory :weather_record do
    temperature { Faker::Number.between(from: -10, to: 40) }
    recorded_at { Faker::Time.backward(days: 14) }
  end
end
