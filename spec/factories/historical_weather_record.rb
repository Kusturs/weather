FactoryBot.define do
  factory :historical_weather_record do
    observation_time { Time.zone.now }
    temperature_celsius { Faker::Number.between(from: -10, to: 40) }
    temperature_fahrenheit { Faker::Number.between(from: -10, to: 40) }
  end
end