require 'rails_helper'

RSpec.describe Weather::Operation::FetchMaxTemperature, type: :operation do
  subject(:operation) { described_class.call }

  let(:data) { [{ 'Temperature' => { 'Metric' => { 'Value' => 15.0 } } }] }

  before do
    allow_any_instance_of(Weather::Operation::FetchMaxTemperature).to receive(:fetch_historical_weather).and_return(data)
    allow_any_instance_of(Weather::Operation::FetchMaxTemperature).to receive(:render_historical_max_temperature).and_raise(StandardError, 'Calculation error')
  end

  it 'handles error during max temperature calculation' do
    expect(operation.success?).to be(false)
    expect(operation[:error]).to eq('Calculation error')
  end
end
