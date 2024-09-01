require 'rails_helper'

RSpec.describe FetchWeatherJob, type: :job do
  subject(:job) { described_class.new(:current) }

  before do
    allow_any_instance_of(WeatherService).to receive(:current_weather).and_return('current_weather_data')
  end

  it 'calls current_weather on WeatherService for :current type' do
    service = instance_double(WeatherService)
    allow(WeatherService).to receive(:new).and_return(service)
    expect(service).to receive(:current_weather)
    job.perform
  end
end
