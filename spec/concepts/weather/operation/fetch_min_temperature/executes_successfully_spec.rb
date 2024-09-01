require 'rails_helper'

RSpec.describe Weather::Operation::FetchMinTemperature, type: :operation do
  subject(:operation) { described_class.call }

  let(:data) do
    [
      { 'Temperature' => { 'Metric' => { 'Value' => 10.0 } } },
      { 'Temperature' => { 'Metric' => { 'Value' => 5.0 } } }
    ]
  end

  before do
    allow_any_instance_of(Weather::Operation::FetchMinTemperature).to receive(:fetch_historical_weather).and_return(data)
    allow_any_instance_of(Weather::Operation::FetchMinTemperature).to receive(:render_historical_min_temperature).and_return(5.0)
  end

  it 'executes successfully and calculates min temperature' do
    expect(operation.success?).to be(true)
    expect(operation[:min_temperature]).to eq(5.0)
  end
end

