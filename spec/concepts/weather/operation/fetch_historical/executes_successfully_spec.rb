require 'rails_helper'

RSpec.describe Weather::Operation::FetchHistorical, type: :operation do
  subject(:operation) { described_class.call }

  let(:weather_data) do
    [
      { 'Temperature' => { 'Metric' => { 'Value' => 20.0 } } },
      { 'Temperature' => { 'Metric' => { 'Value' => 22.0 } } }
    ]
  end

  before do
    allow_any_instance_of(WeatherService).to receive(:historical_weather).and_return(weather_data)
  end

  it 'executes successfully and fetches historical weather data' do
    expect(operation.success?).to be(true)
    expect(operation[:weather_data]).to eq(weather_data)
  end
end
