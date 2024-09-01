require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  subject(:service) { described_class.new }

  it 'calls fetch_weather_data' do
    expect(service).to receive(:fetch_weather_data)
    service.current_weather
  end
end
