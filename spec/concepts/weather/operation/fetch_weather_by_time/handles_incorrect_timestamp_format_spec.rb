require 'rails_helper'

RSpec.describe Weather::Operation::FetchWeatherByTime, type: :operation do
  let(:data) do
    [
      { 'Timestamp' => '2024-09-01T11:00:00Z', 'Temperature' => { 'Metric' => { 'Value' => 15.0 } } }
    ]
  end

  before do
    allow_any_instance_of(Weather::Operation::FetchWeatherByTime).to receive(:fetch_historical_weather).and_return(data)
    allow_any_instance_of(Weather::Operation::FetchWeatherByTime).to receive(:render_weather_by_time).and_return(nil)
  end

  it 'handles incorrect timestamp format gracefully' do
    expect(operation.success?).to be(true)
    expect(operation[:closest_temperature]).to be_nil
  end
end
