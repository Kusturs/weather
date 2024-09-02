require 'rails_helper'

RSpec.describe Weather::Operation::FetchAvgTemperature, type: :operation do
  subject(:operation) { described_class.call }

  context 'when weather data is available' do
    let(:weather_data) do
      [
        { 'Temperature' => { 'Metric' => { 'Value' => 20.0 } } },
        { 'Temperature' => { 'Metric' => { 'Value' => 22.0 } } },
        { 'Temperature' => { 'Metric' => { 'Value' => 24.0 } } }
      ]
    end

    before do
      allow_any_instance_of(WeatherService).to receive(:historical_weather).and_return(weather_data)
    end

    it 'executes successfully and calculates average temperature' do
      expect(operation.success?).to be(true)
      expect(operation[:avg_temperature]).to eq(22.0)
    end
  end

  context 'when weather data is empty' do
    let(:weather_data) { [] }

    before do
      allow_any_instance_of(WeatherService).to receive(:historical_weather).and_return(weather_data)
    end

    it 'handles empty temperature data correctly' do
      expect(operation[:avg_temperature]).to be_nil
    end
  end

  context 'when an error occurs during weather data fetch' do
    before do
      allow_any_instance_of(WeatherService).to receive(:historical_weather).and_raise(StandardError, 'Service unavailable')
    end

    it 'handles error during weather data fetch' do
      expect(operation.success?).to be(false)
      expect(operation[:error]).to eq('Service unavailable')
    end
  end
end
