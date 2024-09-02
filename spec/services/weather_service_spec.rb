require 'rails_helper'

RSpec.describe WeatherService do
  let(:service) { described_class.new }

  describe '#fetch_weather_data_from_db_or_api' do
    let(:latest_record) { instance_double('WeatherRecord', observation_time: 1.hour.ago) }

    context 'when recent data exists in the database' do
      before do
        allow(WeatherRecord).to receive_message_chain(:order, :first).and_return(latest_record)
        allow(service).to receive(:recent_data?).with(latest_record.observation_time).and_return(true)
      end

      it 'returns the latest record' do
        result = service.fetch_weather_data_from_db_or_api
        expect(result).to eq(latest_record)
      end
    end

    context 'when recent data does not exist in the database' do
      before do
        allow(WeatherRecord).to receive_message_chain(:order, :first).and_return(nil)
        allow(service).to receive(:fetch_weather_data).and_return({})
        allow(service).to receive(:save_weather_data)
      end

      it 'fetches new data and saves it' do
        expect(service).to receive(:fetch_weather_data)
        expect(service).to receive(:save_weather_data)
        service.fetch_weather_data_from_db_or_api
      end
    end
  end

  describe '#fetch_historical_weather_from_db_or_api' do
    let(:historical_records) { instance_double('ActiveRecord::Relation') }

    context 'when recent historical data exists' do
      before do
        allow(HistoricalWeatherRecord).to receive(:where).and_return(historical_records)
        allow(historical_records).to receive_message_chain(:order).and_return(historical_records)
        allow(historical_records).to receive(:exists?).and_return(true)
      end

      it 'returns the historical records' do
        result = service.fetch_historical_weather_from_db_or_api
        expect(result).to eq(historical_records)
      end
    end

    context 'when recent historical data does not exist' do
      before do
        allow(HistoricalWeatherRecord).to receive(:where).and_return(historical_records)
        allow(historical_records).to receive_message_chain(:order).and_return(historical_records)
        allow(historical_records).to receive(:exists?).and_return(false)
        allow(service).to receive(:fetch_historical_weather).and_return({})
        allow(service).to receive(:save_historical_weather_data)
      end

      it 'fetches and saves new historical data' do
        expect(service).to receive(:fetch_historical_weather)
        expect(service).to receive(:save_historical_weather_data)
        service.fetch_historical_weather_from_db_or_api
      end
    end
  end

  describe '#fetch_max_temperature_from_db_or_api' do
    let(:max_record) { instance_double('HistoricalWeatherRecord', temperature_celsius: 30) }

    context 'when a max temperature record exists' do
      before do
        allow(HistoricalWeatherRecord).to receive_message_chain(:where, :order, :first).and_return(max_record)
      end

      it 'returns the max temperature record' do
        result = service.fetch_max_temperature_from_db_or_api
        expect(result).to eq(max_record)
      end
    end

    context 'when no max temperature record exists' do
      before do
        allow(HistoricalWeatherRecord).to receive_message_chain(:where, :order, :first).and_return(nil)
        allow(service).to receive(:fetch_historical_weather).and_return({})
        allow(service).to receive(:save_historical_weather_data)
      end

      it 'fetches and saves new historical data, then returns the max temperature record' do
        expect(service).to receive(:fetch_historical_weather)
        expect(service).to receive(:save_historical_weather_data)
        service.fetch_max_temperature_from_db_or_api
      end
    end
  end

  describe '#fetch_min_temperature_from_db_or_api' do
    let(:min_record) { instance_double('HistoricalWeatherRecord', temperature_celsius: 10) }

    context 'when a min temperature record exists' do
      before do
        allow(HistoricalWeatherRecord).to receive_message_chain(:where, :order, :first).and_return(min_record)
      end

      it 'returns the min temperature record' do
        result = service.fetch_min_temperature_from_db_or_api
        expect(result).to eq(min_record)
      end
    end

    context 'when no min temperature record exists' do
      before do
        allow(HistoricalWeatherRecord).to receive_message_chain(:where, :order, :first).and_return(nil)
        allow(service).to receive(:fetch_historical_weather).and_return({})
        allow(service).to receive(:save_historical_weather_data)
      end

      it 'fetches and saves new historical data, then returns the min temperature record' do
        expect(service).to receive(:fetch_historical_weather)
        expect(service).to receive(:save_historical_weather_data)
        service.fetch_min_temperature_from_db_or_api
      end
    end
  end

describe '#fetch_avg_temperature_from_db_or_api' do
    context 'when records exist' do
      let(:records) { instance_double(ActiveRecord::Relation, exists?: true) }

      before do
        allow(HistoricalWeatherRecord).to receive(:where).and_return(records)
        allow(records).to receive(:map).and_return([10, 20, 30])
      end

      it 'returns the average temperature' do
        result = service.fetch_avg_temperature_from_db_or_api
        expect(result).to eq(20) # Среднее значение температуры
      end
    end

    context 'when no records exist' do
      let(:empty_records) { instance_double(ActiveRecord::Relation, exists?: false) }
      let(:new_records) { instance_double(ActiveRecord::Relation, exists?: true) }

      before do
        allow(HistoricalWeatherRecord).to receive(:where).and_return(empty_records, new_records)
        allow(service).to receive(:fetch_historical_weather).and_return({})
        allow(service).to receive(:save_historical_weather_data)
        allow(new_records).to receive(:map).and_return([10, 20, 30])
      end

      it 'fetches and saves new historical data, then calculates the average temperature' do
        expect(service).to receive(:fetch_historical_weather).once
        expect(service).to receive(:save_historical_weather_data).once

        result = service.fetch_avg_temperature_from_db_or_api

        expect(result).to eq(20) # Среднее значение температуры
      end
    end
  end

  describe '#fetch_weather_by_time_from_db_or_api' do
    let(:closest_record) { instance_double('WeatherRecord', observation_time: 1.hour.ago) }
    let(:timestamp) { 1_635_000_000 } # Example Unix timestamp

    context 'when a closest record exists' do
      before do
        allow(WeatherRecord).to receive_message_chain(:select, :order, :first).and_return(closest_record)
      end

      it 'returns the closest weather record' do
        result = service.fetch_weather_by_time_from_db_or_api(timestamp)
        expect(result).to eq(closest_record)
      end
    end

    context 'when no closest record exists' do
      before do
        allow(WeatherRecord).to receive_message_chain(:select, :order, :first).and_return(nil)
        allow(service).to receive(:fetch_historical_weather).and_return({})
        allow(service).to receive(:save_historical_weather_data)
      end

      it 'fetches and saves new historical data, then returns the closest weather record' do
        expect(service).to receive(:fetch_historical_weather)
        expect(service).to receive(:save_historical_weather_data)
        service.fetch_weather_by_time_from_db_or_api(timestamp)
      end
    end
  end

  describe '#historical_weather' do
    it 'calls fetch_historical_weather' do
      expect(service).to receive(:fetch_historical_weather)
      service.historical_weather
    end
  end

  describe '#fetch_historical_weather_async' do
    it 'enqueues a FetchWeatherJob with the :historical type' do
      expect(Delayed::Job).to receive(:enqueue).with(instance_of(FetchWeatherJob))
      service.fetch_historical_weather_async
    end
  end
end

