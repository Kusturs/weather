require 'rails_helper'

RSpec.describe Weather::Operation::FetchMinTemperature, type: :operation do
  subject(:operation) { described_class.call }

  before do
    allow_any_instance_of(Weather::Operation::FetchMinTemperature).to receive(:fetch_historical_weather).and_return(nil)
  end

  it 'handles empty data correctly' do
    expect(operation.success?).to be(false)
    expect(operation[:data]).to be_nil
  end
end

