require 'rails_helper'

RSpec.describe FetchWeatherJob, type: :job do
  context 'when job type is :current' do
    subject(:job) { described_class.new(:current) }

    it 'calls perform with current type' do
      expect(job.type).to eq(:current)
      expect {
        job.perform
      }.to_not raise_error
    end

    it 'has a maximum of 3 attempts' do
      expect(job.max_attempts).to eq(3)
    end

    it 'calls current_weather on WeatherService' do
      service = instance_double(WeatherService)
      allow(WeatherService).to receive(:new).and_return(service)
      allow_any_instance_of(WeatherService).to receive(:current_weather).and_return('current_weather_data')
      expect(service).to receive(:current_weather)
      job.perform
    end

    context 'when an error occurs during perform' do
      before do
        allow_any_instance_of(WeatherService).to receive(:current_weather).and_raise(StandardError, 'Test error')
        allow(Rails.logger).to receive(:error)
      end

      it 'logs an error message on failure' do
        expect(Rails.logger).to receive(:error).with("FetchWeatherJob failed for type: #{job.type}")
        job.perform
      end
    end
  end

  context 'when job type is :historical' do
    subject(:job) { described_class.new(:historical) }

    it 'calls perform with historical type' do
      expect(job.type).to eq(:historical)
      expect {
        job.perform
      }.to_not raise_error
    end

    it 'calls historical_weather on WeatherService' do
      service = instance_double(WeatherService)
      allow(WeatherService).to receive(:new).and_return(service)
      allow_any_instance_of(WeatherService).to receive(:historical_weather).and_return('historical_weather_data')
      expect(service).to receive(:historical_weather)
      job.perform
    end
  end
end
