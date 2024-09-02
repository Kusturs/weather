require 'rails_helper'

RSpec.describe Weather::Operation::FetchAvgTemperature do
  let(:weather_service) { instance_double("WeatherService") }

  before do
    allow(WeatherService).to receive(:new).and_return(weather_service)
  end

  context 'when average temperature is successfully fetched' do
    let(:avg_temperature) { 25.0 }

    before do
      allow(weather_service).to receive(:fetch_avg_temperature_from_db_or_api).and_return(avg_temperature)
    end

    it 'is successful' do
      result = described_class.call
      expect(result[:success]).to be(true)
    end

    it 'sets the avg_temperature in the context' do
      result = described_class.call
      expect(result[:avg_temperature]).to eq({ avg_temp_metric: avg_temperature })
    end
  end

  context 'when fetching average temperature fails' do
    before do
      allow(weather_service).to receive(:fetch_avg_temperature_from_db_or_api).and_return(nil)
    end

    it 'is not successful' do
      result = described_class.call
      expect(result[:success]).to be(false)
    end

    it 'sets an error message in the context' do
      result = described_class.call
      expect(result[:error]).to eq('Ошибка: Не удалось получить данные')
    end
  end
end

