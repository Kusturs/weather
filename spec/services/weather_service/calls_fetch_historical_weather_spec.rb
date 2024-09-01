require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  subject(:service) { described_class.new }

  it 'calls fetch_historical_weather' do
    expect(service).to receive(:fetch_historical_weather)
    service.historical_weather
  end
end
