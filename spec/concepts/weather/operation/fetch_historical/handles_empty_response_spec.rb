require 'rails_helper'

RSpec.describe Weather::Operation::FetchHistorical, type: :operation do
  subject(:operation) { described_class.call }

  before do
    allow_any_instance_of(WeatherService).to receive(:historical_weather).and_return(nil)
  end

  it 'handles empty response from weather service' do
    expect(operation[:weather_data]).to be_nil
  end
end
