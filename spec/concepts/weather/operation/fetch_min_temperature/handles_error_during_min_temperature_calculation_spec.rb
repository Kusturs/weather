require 'rails_helper'

RSpec.describe Weather::Operation::FetchMinTemperature, type: :operation do
  subject(:operation) { described_class.call }

  let(:data) { [{ 'Temperature' => { 'Metric' => { 'Value' => 10.0 } } }] }

  before do
    allow_any_instance_of(Weather::Operation::FetchMinTemperature).to receive(:fetch_historical_weather).and_return(data)
    allow_any_instance_of(Weather::Operation::FetchMinTemperature).to receive(:render_historical_min_temperature).and_raise(StandardError, 'Calculation error')
  end

  it 'handles error during min temperature calculation' do
    expect(operation.success?).to be(false)
    expect(operation[:error]).to eq('Calculation error')
  end
end

