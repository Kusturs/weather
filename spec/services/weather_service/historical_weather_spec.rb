require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  subject(:service) { described_class.new }

  before do
    allow(service).to receive(:fetch_historical_weather).and_return('fake_historical_weather_data')
  end

  it 'returns historical weather data' do
    expect(service.historical_weather).to eq('fake_historical_weather_data')
  end
end
