require 'rails_helper'

RSpec.describe FetchWeatherJob, type: :job do
  subject(:job) { described_class.new(:current) }

  before do
    allow_any_instance_of(WeatherService).to receive(:current_weather).and_raise(StandardError, 'Test error')
    allow(Rails.logger).to receive(:error)
  end

  it 'logs an error message on failure' do
    expect(Rails.logger).to receive(:error).with("FetchWeatherJob failed for type: #{job.type}")
    job.perform
  end
end
