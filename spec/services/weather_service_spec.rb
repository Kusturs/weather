require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  subject(:service) { described_class.new }

  context 'when testing method calls' do
    it 'calls fetch_weather_data when current_weather is called' do
      expect(service).to receive(:fetch_weather_data)
      service.current_weather
    end

    it 'calls fetch_historical_weather when historical_weather is called' do
      expect(service).to receive(:fetch_historical_weather)
      service.historical_weather
    end
  end

  context 'when testing return values' do
    before do
      allow(service).to receive(:fetch_weather_data).and_return('fake_current_weather_data')
    end

    it 'returns current weather data' do
      expect(service.current_weather).to eq('fake_current_weather_data')
    end

    before do
      allow(service).to receive(:fetch_historical_weather).and_return('fake_historical_weather_data')
    end

    it 'returns historical weather data' do
      expect(service.historical_weather).to eq('fake_historical_weather_data')
    end
  end

  context 'when testing job enqueuing' do
    it 'enqueues a job to fetch current weather' do
      expect {
        service.fetch_current_weather_async
      }.to change(Delayed::Job, :count).by(1)

      job = Delayed::Job.last
      expect(job.handler).to include('FetchWeatherJob')
      expect(job.handler).to include(':current')
    end

    it 'enqueues a job to fetch historical weather' do
      expect {
        service.fetch_historical_weather_async
      }.to change(Delayed::Job, :count).by(1)

      job = Delayed::Job.last
      expect(job.handler).to include('FetchWeatherJob')
      expect(job.handler).to include(':historical')
    end
  end
end
