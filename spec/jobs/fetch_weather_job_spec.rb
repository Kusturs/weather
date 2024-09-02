require 'rails_helper'

RSpec.describe FetchWeatherJob do
  let(:service) { instance_double("WeatherService") }
  let(:logger) { instance_double("Rails.logger") }

  before do
    allow(WeatherService).to receive(:new).and_return(service)
    allow(Rails.logger).to receive(:error)
    allow(service).to receive(:historical_weather)
  end

  describe '#perform' do
    context 'when type is :historical' do
      subject { described_class.new(:historical) }

      it 'calls historical_weather on WeatherService' do
        expect(service).to receive(:historical_weather)
        subject.perform
      end

      it 'does not log an error' do
        expect(Rails.logger).not_to receive(:error)
        subject.perform
      end
    end

    context 'when type is unknown' do
      subject { described_class.new(:unknown) }

      it 'logs an error' do
        expect(Rails.logger).to receive(:error).with("Unknown job type: #{subject.type}")
        subject.perform
      end

      it 'does not call historical_weather on WeatherService' do
        expect(service).not_to receive(:historical_weather)
        subject.perform
      end
    end
  end

  describe '#max_attempts' do
    subject { described_class.new(:historical) }

    it 'returns the maximum number of attempts' do
      expect(subject.max_attempts).to eq(3)
    end
  end

  describe '#failure' do
    subject { described_class.new(:historical) }

    it 'logs an error message' do
      expect(Rails.logger).to receive(:error).with("FetchWeatherJob failed for type: #{subject.type}")
      subject.failure
    end
  end
end

