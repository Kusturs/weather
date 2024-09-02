require 'rails_helper'

RSpec.describe Weather::Operation::FetchWeatherByTime do
  let(:weather_service) { instance_double("WeatherService") }
  let(:helpers) { spy("Helpers") }
  let(:timestamp) { '2024-09-01 15:00:00' }
  let(:params) { { timestamp: timestamp } }
  let(:closest_record) { { temp: 22.5, timestamp: timestamp } }
  let(:rendered_temperature) { "Temperature at #{timestamp}: 22.5°C" }

  before do
    allow(WeatherService).to receive(:new).and_return(weather_service)
  end

  context 'when weather data is successfully fetched' do
    before do
      allow(weather_service).to receive(:fetch_weather_by_time_from_db_or_api).with(timestamp).and_return(closest_record)
      allow(helpers).to receive(:render_weather_by_time).with(closest_record).and_return(rendered_temperature)
    end

    it 'calls fetch_weather_by_time_from_db_or_api with the correct timestamp' do
      described_class.call(params: params, helpers: helpers)
      expect(weather_service).to have_received(:fetch_weather_by_time_from_db_or_api).with(timestamp)
    end

    it 'is successful' do
      result = described_class.call(params: params, helpers: helpers)
      expect(result[:success]).to be(true)
    end

    it 'sets the closest_temperature in the context' do
      result = described_class.call(params: params, helpers: helpers)
      expect(result[:closest_temperature]).to eq(rendered_temperature)
    end

    it 'calls render_weather_by_time with the correct record' do
      described_class.call(params: params, helpers: helpers)
      expect(helpers).to have_received(:render_weather_by_time).with(closest_record)
    end
  end

  context 'when fetching weather data fails' do
    before do
      allow(weather_service).to receive(:fetch_weather_by_time_from_db_or_api).with(timestamp).and_return(nil)
    end

    it 'is not successful' do
      result = described_class.call(params: params, helpers: helpers)
      expect(result[:success]).to be(false)
    end

    it 'sets an error message in the context' do
      result = described_class.call(params: params, helpers: helpers)
      expect(result[:error]).to eq('Ошибка: Не удалось получить данные за эту дату')
    end

    it 'does not call render_weather_by_time' do
      described_class.call(params: params, helpers: helpers)
      expect(helpers).not_to have_received(:render_weather_by_time)
    end
  end
end

