require 'rails_helper'

RSpec.describe Weather::Operation::FetchAvgTemperature, type: :operation do
  subject(:operation) { described_class.call }

  before do
    allow_any_instance_of(WeatherService).to receive(:historical_weather).and_raise(StandardError, 'Service unavailable')
  end

  it 'handles error during weather data fetch' do
    expect(operation.success?).to be(false)
    expect(operation[:error]).to eq('Service unavailable')
  end
end
