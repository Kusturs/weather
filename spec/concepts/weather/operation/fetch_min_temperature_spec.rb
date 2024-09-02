require 'rails_helper'

RSpec.describe Weather::Operation::FetchMinTemperature do
  let(:weather_service) { instance_double("WeatherService") }
  let(:helpers) { instance_double("Helpers") }
  let(:min_record) { { temp: -10.0, date: '2023-01-01' } }
  let(:rendered_min_temperature) { "Min temperature: -10.0°C on 2023-01-01" }

  before do
    allow(WeatherService).to receive(:new).and_return(weather_service)
  end

  context 'when min temperature is successfully fetched' do
    before do
      allow(weather_service).to receive(:fetch_min_temperature_from_db_or_api).and_return(min_record)
      allow(helpers).to receive(:render_historical_min_temperature).with([min_record]).and_return(rendered_min_temperature)
    end

    it 'is successful' do
      result = described_class.call(helpers: helpers)
      expect(result[:success]).to be(true)
    end

    it 'sets the min_temperature in the context' do
      result = described_class.call(helpers: helpers)
      expect(result[:min_temperature]).to eq(rendered_min_temperature)
    end
  end

  context 'when fetching min temperature fails' do
    before do
      allow(weather_service).to receive(:fetch_min_temperature_from_db_or_api).and_return(nil)
    end

    it 'is not successful' do
      result = described_class.call(helpers: helpers)
      expect(result[:success]).to be(false)
    end

    it 'sets an error message in the context' do
      result = described_class.call(helpers: helpers)
      expect(result[:error]).to eq('Ошибка: Не удалось получить данные')
    end
  end
end

