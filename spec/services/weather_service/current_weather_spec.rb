require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  subject(:service) { described_class.new }

  before do
    allow(service).to receive(:fetch_weather_data).and_return('fake_current_weather_data')
  end

  it 'returns current weather data' do
    expect(service.current_weather).to eq('fake_current_weather_data')
  end
end
