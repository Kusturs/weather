require 'swagger_helper'

RSpec.describe 'Weather API', type: :request do
  path '/api/v1/weather/current' do
    get 'Get the current temperature' do
      tags 'Weather'
      produces 'application/json'

      response '200', 'successful' do
        let(:weather_record) { create(:weather_record) }

        before do
          allow_any_instance_of(WeatherService).to receive(:fetch_weather_data_from_db_or_api).and_return(weather_record)
        end

        run_test!
      end
    end
  end

  path '/api/v1/weather/historical' do
    get 'Get hourly temperatures for the last 24 hours' do
      tags 'Weather'
      produces 'application/json'

      response '200', 'successful' do
        let(:historical_weather_record) do
          [create(:historical_weather_record)]
        end

        before do
          allow_any_instance_of(WeatherService).to receive(:fetch_historical_weather_from_db_or_api).and_return(historical_weather_record)
        end

        run_test!
      end

    end
  end

  path '/api/v1/weather/historical/max' do
    get 'Get maximum temperature for the last 24 hours' do
      tags 'Weather'
      produces 'application/json'

      response '200', 'successful' do
        let(:max_temperature_celsius) { create(:historical_weather_record) }

        before do
          allow_any_instance_of(WeatherService).to receive(:fetch_max_temperature_from_db_or_api).and_return(max_temperature_celsius)
        end

        run_test!
      end
    end
  end

  path '/api/v1/weather/historical/min' do
    get 'Get minimum temperature for the last 24 hours' do
      tags 'Weather'
      produces 'application/json'
      response '200', 'successful' do
        let(:min_temperature_celsius) { create(:historical_weather_record) }

        before do
          allow_any_instance_of(WeatherService).to receive(:fetch_min_temperature_from_db_or_api).and_return(min_temperature_celsius)
        end

        run_test!
      end
    end
  end

  path '/api/v1/weather/historical/avg' do
    get 'Get average temperature for the last 24 hours' do
      tags 'Weather'
      produces 'application/json'

      response '200', 'successful' do
        let(:avg_temperature_celsius) { create(:historical_weather_record) }

        before do
          allow_any_instance_of(WeatherService).to receive(:fetch_avg_temperature_from_db_or_api).and_return(avg_temperature_celsius)
        end

        run_test!
      end
    end
  end

  path '/api/v1/weather/by_time' do
    get 'Get temperature closest to the given timestamp' do
      tags 'Weather'
      produces 'application/json'
      parameter name: :timestamp, in: :query, type: :integer, description: 'Unix timestamp', required: true

      response '200', 'successful' do
        let(:timestamp) { Time.now.to_i }
        let(:temperature_celsius) { create(:weather_record) }

        before do
          allow_any_instance_of(WeatherService).to receive(:fetch_weather_by_time_from_db_or_api).and_return(temperature_celsius)
        end

        run_test! do |response|
          expect(response.status).to eq(200)
        end
      end
    end
  end

  path '/api/v1/health' do
    get 'Health check' do
      tags 'Health'
      produces 'application/json'

      response '200', 'successful' do
        run_test!
      end
    end
  end
end
