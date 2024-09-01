require 'rails_helper'
require 'vcr'

RSpec.describe 'Weather API', type: :request do
  describe 'GET /api/v1/weather/current' do
    it 'returns the current weather', vcr: { cassette_name: 'current_weather' } do
      get '/api/v1/weather/current'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('temperature_celsius')
      expect(json).to have_key('temperature_fahrenheit')
    end
  end

  describe 'GET /api/v1/weather/historical' do
    it 'returns hourly temperatures for the last 24 hours', vcr: { cassette_name: 'historical_weather' } do
      get '/api/v1/weather/historical'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to be_an(Array)
      expect(json.first).to have_key('observation_time')
      expect(json.first).to have_key('metric_temp')
      expect(json.first).to have_key('imperial_temp')
    end
  end

  describe 'GET /api/v1/weather/historical/max' do
    it 'returns the maximum temperature for the last 24 hours', vcr: { cassette_name: 'max_temperature' } do
      get '/api/v1/weather/historical/max'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('max_temp_imperial')
    end
  end

  describe 'GET /api/v1/weather/historical/min' do
    it 'returns the minimum temperature for the last 24 hours', vcr: { cassette_name: 'min_temperature' } do
      get '/api/v1/weather/historical/min'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('min_temp_imperial')
    end
  end

  describe 'GET /api/v1/weather/historical/avg' do
    it 'returns the average temperature for the last 24 hours', vcr: { cassette_name: 'avg_temperature' } do
      get '/api/v1/weather/historical/avg'
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('avg_temp_metric')
    end
  end

  describe 'GET /api/v1/weather/by_time' do
    it 'returns the temperature closest to the given timestamp', vcr: { cassette_name: 'weather_by_time' } do
      get '/api/v1/weather/by_time', params: { timestamp: 1621823799 }
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json).to have_key('temperature_celsius')
      expect(json).to have_key('temperature_fahrenheit')
    end
  end
end
