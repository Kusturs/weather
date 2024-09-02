class HistoricalWeatherRecord < ApplicationRecord
  # validates :observation_time, presence: true, uniqueness: true
  validates :temperature_celsius, :temperature_fahrenheit, presence: true
end
