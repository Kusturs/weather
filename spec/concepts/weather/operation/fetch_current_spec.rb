require 'rails_helper'

RSpec.describe Weather::Operation::FetchCurrent do
  let(:weather_service) { instance_double("WeatherService") }
  let(:weather_record) { { temp: 25.5, condition: 'Sunny' } }

  before do
    allow(WeatherService).to receive(:new).and_return(weather_service)
  end

  context 'when weather data is successfully fetched' do
    before do
      allow(weather_service).to receive(:fetch_weather_data_from_db_or_api).and_return(weather_record)
    end

    it 'calls fetch_weather_data_from_db_or_api' do
      described_class.call
      expect(weather_service).to have_received(:fetch_weather_data_from_db_or_api)
    end

    it 'is successful' do
      result = described_class.call
      expect(result[:success]).to be(true)
    end

    it 'sets the weather_data in the context' do
      result = described_class.call
      expect(result[:weather_data]).to eq(weather_record)
    end
  end

  context 'when fetching weather data fails' do
    before do
      allow(weather_service).to receive(:fetch_weather_data_from_db_or_api).and_return(nil)
    end

    it 'calls fetch_weather_data_from_db_or_api' do
      described_class.call
      expect(weather_service).to have_received(:fetch_weather_data_from_db_or_api)
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
end

