require 'rails_helper'

RSpec.describe WeatherHelpers do
  include WeatherHelpers

  let(:current_weather_data) do
    {
      'Temperature' => {
        'Metric' => { 'Value' => 25.0 },
        'Imperial' => { 'Value' => 77.0 }
      }
    }
  end

  let(:historical_weather_data) do
    [
      {
        'Temperature' => { 'Metric' => { 'Value' => 20.0 }, 'Imperial' => { 'Value' => 68.0 } },
        'LocalObservationDateTime' => '2024-08-31T10:00:00+03:00'
      },
      {
        'Temperature' => { 'Metric' => { 'Value' => 30.0 }, 'Imperial' => { 'Value' => 86.0 } },
        'LocalObservationDateTime' => '2024-08-31T14:00:00+03:00'
      },
      {
        'Temperature' => { 'Metric' => { 'Value' => 25.0 }, 'Imperial' => { 'Value' => 77.0 } },
        'LocalObservationDateTime' => '2024-08-31T12:00:00+03:00'
      }
    ]
  end

  describe '#fetch_weather_data' do
    it 'returns parsed JSON data' do
      allow(Net::HTTP).to receive(:get).and_return(current_weather_data.to_json)
      result = fetch_weather_data
      expect(result).to eq(current_weather_data)
    end

    it 'handles errors and returns nil' do
      allow(Net::HTTP).to receive(:get).and_raise(StandardError)
      result = fetch_weather_data
      expect(result).to be_nil
    end
  end

  describe '#fetch_historical_weather' do
    it 'returns parsed JSON data' do
      allow(Net::HTTP).to receive(:get).and_return(historical_weather_data.to_json)
      result = fetch_historical_weather
      expect(result).to eq(historical_weather_data)
    end
  end

  describe '#render_current_weather' do
    it 'renders the current weather in Celsius and Fahrenheit' do
      result = render_current_weather(current_weather_data)
      expect(result).to eq({ temperature_celsius: 25.0, temperature_fahrenheit: 77.0 })
    end
  end

  describe '#render_historical_max_temperature' do
    it 'renders the max temperature data' do
      result = render_historical_max_temperature(historical_weather_data)
      expect(result).to eq({
                             max_temp_metric: 30.0,
                             max_temp_imperial: 86.0,
                             time: '2024-08-31T14:00:00+03:00'
                           })
    end
  end

  describe '#render_historical_min_temperature' do
    it 'renders the min temperature data' do
      result = render_historical_min_temperature(historical_weather_data)
      expect(result).to eq({
                             min_temp_metric: 20.0,
                             min_temp_imperial: 68.0,
                             time: '2024-08-31T10:00:00+03:00'
                           })
    end
  end

  describe '#render_historical_avg_temperature' do
    it 'renders the average temperature' do
      result = render_historical_avg_temperature(historical_weather_data)
      expect(result).to eq({ avg_temp_metric: 25.0 })
    end

    it 'handles empty data array' do
      expect { render_historical_avg_temperature([]) }.to raise_error(RuntimeError, /Ошибка: Нет данных для расчета средней температуры/)
    end
  end

  describe '#render_weather_by_time' do
    it 'returns the closest weather data by timestamp' do
      timestamp = Time.parse('2024-08-31T12:30:00+03:00').to_i
      result = render_weather_by_time(historical_weather_data, timestamp)
      expect(result).to eq({
                             temperature_celsius: 25.0,
                             temperature_fahrenheit: 77.0
                           })
    end

    it 'handles no matching data' do
      timestamp = Time.parse('2025-08-31T12:30:00+03:00').to_i
      expect { render_weather_by_time([], timestamp) }.to raise_error(RuntimeError, /Ошибка: Нет данных для заданного времени/)
    end
  end
end
