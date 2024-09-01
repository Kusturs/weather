require 'rails_helper'

RSpec.describe Weather::Operation::FetchWeatherByTime, type: :operation do
  subject(:operation) { described_class.call(params: { timestamp: '2024-01-01T12:00:00Z' }) }

  let(:data) do
    [
      { 'Timestamp' => '2024-01-01T12:00:00Z', 'Temperature' => { 'Metric' => { 'Value' => 15.0 } } },
      { 'Timestamp' => '2024-01-01T13:00:00Z', 'Temperature' => { 'Metric' => { 'Value' => 18.0 } } }
    ]
  end

  before do
    allow_any_instance_of(Weather::Operation::FetchWeatherByTime).to receive(:fetch_historical_weather).and_return(data)
    allow_any_instance_of(Weather::Operation::FetchWeatherByTime).to receive(:render_weather_by_time).with(data, '2024-01-01T12:00:00Z').and_return(15.0)
  end

  it 'executes successfully and finds the closest temperature' do
    expect(operation.success?).to be(true)
    expect(operation[:closest_temperature]).to eq(15.0)
  end
end
