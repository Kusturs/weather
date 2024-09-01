require 'rails_helper'

RSpec.describe Weather::Operation::FetchMaxTemperature, type: :operation do
  subject(:operation) { described_class.call }

  let(:data) do
    [
      { 'SomeOtherField' => 'value' }
    ]
  end

  before do
    allow_any_instance_of(Weather::Operation::FetchMaxTemperature).to receive(:fetch_historical_weather).and_return(data)
    allow_any_instance_of(Weather::Operation::FetchMaxTemperature).to receive(:render_historical_max_temperature).and_return(nil)
  end

  it 'handles no temperature data in the response' do
    expect(operation.success?).to be(true)
    expect(operation[:max_temperature]).to be_nil
  end
end
