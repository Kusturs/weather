require 'rails_helper'

RSpec.describe Weather::Operation::FetchMinTemperature, type: :operation do
  let(:data) do
    [
      { 'SomeOtherField' => 'value' }
    ]
  end

  before do
    allow_any_instance_of(Weather::Operation::FetchMinTemperature).to receive(:fetch_historical_weather).and_return(data)
    allow_any_instance_of(Weather::Operation::FetchMinTemperature).to receive(:render_historical_min_temperature).and_return(nil)
  end

  it 'handles no temperature data in the response' do
    expect(operation.success?).to be(true)
    expect(operation[:min_temperature]).to be_nil
  end
end

