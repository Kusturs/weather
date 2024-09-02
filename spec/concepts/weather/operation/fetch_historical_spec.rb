require 'rails_helper'

RSpec.describe Weather::Operation::FetchHistorical do
  let(:weather_service) { instance_double("WeatherService") }
  let(:weather_records) { [{ temp: 20.0, date: '2023-08-01' }, { temp: 22.0, date: '2023-08-02' }] }

  before do
    allow(WeatherService).to receive(:new).and_return(weather_service)
  end

  context 'when historical weather data is successfully fetched' do
    before do
      allow(weather_service).to receive(:fetch_historical_weather_from_db_or_api).and_return(weather_records)
    end

    it 'calls fetch_historical_weather_from_db_or_api' do
      described_class.call
      expect(weather_service).to have_received(:fetch_historical_weather_from_db_or_api)
    end

    it 'is successful' do
      result = described_class.call
      expect(result[:success]).to be(true)
    end

    it 'sets the weather_data in the context' do
      result = described_class.call
      expect(result[:weather_data]).to eq(weather_records)
    end
  end

  context 'when fetching historical weather data returns an empty list' do
    before do
      allow(weather_service).to receive(:fetch_historical_weather_from_db_or_api).and_return([])
    end

    it 'calls fetch_historical_weather_from_db_or_api' do
      described_class.call
      expect(weather_service).to have_received(:fetch_historical_weather_from_db_or_api)
    end

    it 'is not successful' do
      result = described_class.call
      expect(result[:success]).to be(false)
    end

    it 'sets an error message in the context' do
      result = described_class.call
      expect(result[:error]).to eq('Ошибка: Не удалось получить данные')
    end

    it 'does not set weather_data in the context' do
      result = described_class.call
      expect(result[:weather_data]).to be_nil
    end
  end

  context 'when fetching historical weather data fails' do
    before do
      allow(weather_service).to receive(:fetch_historical_weather_from_db_or_api).and_raise(StandardError, 'Service unavailable')
    end

    it 'raises an error' do
      expect { described_class.call }.to raise_error(StandardError, 'Service unavailable')
    end
  end
end

