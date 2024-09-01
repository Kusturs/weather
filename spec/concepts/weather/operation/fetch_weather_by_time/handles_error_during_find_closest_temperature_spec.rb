require 'rails_helper'

RSpec.describe Weather::Operation::FetchWeatherByTime, type: :operation do
  subject(:operation) { described_class.call(params: { timestamp: '2024-09-01T12:00:00Z' }) }

  let(:data) do
    [
      { 'Timestamp' => '2024-09-01T11:00:00Z', 'Temperature' => { 'Metric' => { 'Value' => 15.0 } } }
    ]
  end

  before do
    allow_any_instance_of(Weather::Operation::FetchWeatherByTime).to receive(:fetch_historical_weather).and_return(data)
    allow_any_instance_of(Weather::Operation::FetchWeatherByTime).to receive(:render_weather_by_time).and_raise(StandardError, 'Calculation error')
  end

  it 'handles error during finding closest temperature' do
    expect(operation.success?).to be(false)
    expect(operation[:error]).to eq('Calculation error')
  end
end
