require 'rails_helper'

RSpec.describe Weather::Operation::FetchWeatherByTime, type: :operation do
  subject(:operation) { described_class.call(params: params) }

  context 'when the timestamp is valid and data is available' do
    let(:params) { { timestamp: '2024-01-01T12:00:00Z' } }
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

  context 'when the timestamp is valid but no data is returned' do
    let(:params) { { timestamp: '2024-09-01T12:00:00Z' } }

    before do
      allow_any_instance_of(Weather::Operation::FetchWeatherByTime).to receive(:fetch_historical_weather).and_return(nil)
    end

    it 'handles empty data correctly' do
      expect(operation.success?).to be(false)
      expect(operation[:data]).to be_nil
    end
  end

  context 'when there is an error during calculation' do
    let(:params) { { timestamp: '2024-09-01T12:00:00Z' } }
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

  context 'when the timestamp format is incorrect' do
    let(:params) { { timestamp: 'invalid-timestamp-format' } }
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
end
