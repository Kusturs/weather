require 'rails_helper'

RSpec.describe Weather::Operation::FetchMaxTemperature do
  let(:weather_service) { instance_double("WeatherService") }
  let(:helpers) { instance_double("Helpers") }
  let(:max_record) { { temp: 35.0, date: '2023-09-01' } }
  let(:rendered_max_temperature) { "Max temperature: 35.0°C on 2023-09-01" }

  before do
    allow(WeatherService).to receive(:new).and_return(weather_service)
  end

  context 'when max temperature is successfully fetched' do
    before do
      allow(weather_service).to receive(:fetch_max_temperature_from_db_or_api).and_return(max_record)
      allow(helpers).to receive(:render_historical_max_temperature).with([max_record]).and_return(rendered_max_temperature)
    end

    it 'is successful' do
      result = described_class.call(helpers: helpers)
      expect(result[:success]).to be(true)
    end

    it 'sets the max_temperature in the context' do
      result = described_class.call(helpers: helpers)
      expect(result[:max_temperature]).to eq(rendered_max_temperature)
    end
  end

  context 'when fetching max temperature fails' do
    before do
      allow(weather_service).to receive(:fetch_max_temperature_from_db_or_api).and_return(nil)
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

