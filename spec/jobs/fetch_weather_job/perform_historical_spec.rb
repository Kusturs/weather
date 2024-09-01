require 'rails_helper'

RSpec.describe FetchWeatherJob, type: :job do
  subject(:job) { described_class.new(:historical) }

  before do
    allow_any_instance_of(WeatherService).to receive(:historical_weather).and_return('historical_weather_data')
  end

  it 'calls historical_weather on WeatherService for :historical type' do
    service = instance_double(WeatherService)
    allow(WeatherService).to receive(:new).and_return(service)
    expect(service).to receive(:historical_weather)
    job.perform
  end
end
