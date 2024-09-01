require 'rails_helper'

RSpec.describe Weather::Operation::FetchAvgTemperature, type: :operation do
  subject(:operation) { described_class.call }

  let(:weather_data) { [] }

  before do
    allow_any_instance_of(WeatherService).to receive(:historical_weather).and_return(weather_data)
  end

  it 'handles empty temperature data correctly' do
    expect(operation[:avg_temperature]).to be_nil
  end
end
