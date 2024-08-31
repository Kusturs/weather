# spec/api/request/weather_api_spec.rb
require 'rails_helper'

RSpec.describe 'Weather API', type: :request do
  describe 'GET /api/v1/weather/current' do
    it 'returns the current temperature' do
      VCR.use_cassette('weather_api_current') do
        get '/api/v1/weather/current'

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to include('temperature_celsius', 'temperature_fahrenheit')
      end
    end
  end

  describe 'GET /api/v1/weather/historical' do
    it 'returns hourly temperatures for the last 24 hours' do
      VCR.use_cassette('weather_api_historical') do
        get '/api/v1/weather/historical'

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to be_an(Array)
        expect(json_response.first).to include('observation_time', 'metric_temp', 'imperial_temp')
      end
    end
  end

  describe 'GET /api/v1/weather/historical/max' do
    it 'returns the maximum temperature for the last 24 hours' do
      VCR.use_cassette('weather_api_historical_max') do
        get '/api/v1/weather/historical/max'

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to include('max_temp_metric', 'max_temp_imperial', 'time')
      end
    end
  end

  describe 'GET /api/v1/weather/historical/min' do
    it 'returns the minimum temperature for the last 24 hours' do
      VCR.use_cassette('weather_api_historical_min') do
        get '/api/v1/weather/historical/min'

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to include('min_temp_metric', 'min_temp_imperial', 'time')
      end
    end
  end

  describe 'GET /api/v1/weather/historical/avg' do
    it 'returns the average temperature for the last 24 hours' do
      VCR.use_cassette('weather_api_historical_avg') do
        get '/api/v1/weather/historical/avg'

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to include('avg_temp_metric')
      end
    end
  end

  describe 'GET /api/v1/weather/by_time' do
    it 'returns the temperature closest to the given timestamp' do
      VCR.use_cassette('weather_api_by_time') do
        timestamp = Time.now.to_i
        get '/api/v1/weather/by_time', params: { timestamp: timestamp }

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response).to include('temperature_celsius', 'temperature_fahrenheit')
      end
    end
  end

  describe 'GET /api/v1/health' do
    it 'returns the backend status' do
      get '/api/v1/health'

      expect(response).to have_http_status(:ok)
      json_response = JSON.parse(response.body)
      expect(json_response).to include('status' => 'OK')
    end
  end
end
