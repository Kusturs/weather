require 'rails_helper'

RSpec.describe Weather::Operation::FetchWeatherByTime, type: :operation do
  subject(:operation) { described_class.call(params: { timestamp: '2024-09-01T12:00:00Z' }) }

  before do
    allow_any_instance_of(Weather::Operation::FetchWeatherByTime).to receive(:fetch_historical_weather).and_return(nil)
  end

  it 'handles empty data correctly' do
    expect(operation.success?).to be(false)
    expect(operation[:data]).to be_nil
  end
end
