require 'rails_helper'

RSpec.describe WeatherService, type: :service do
  subject(:service) { described_class.new }

  it 'enqueues a job to fetch historical weather' do
    expect {
      service.fetch_historical_weather_async
    }.to change(Delayed::Job, :count).by(1)

    job = Delayed::Job.last
    expect(job.handler).to include('FetchWeatherJob')
    expect(job.handler).to include(':historical')
  end
end
