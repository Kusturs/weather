require 'rails_helper'

RSpec.describe Weather::Operation::FetchCurrent, type: :operation do
  subject(:operation) { described_class.call }

  let(:weather_data) { { 'Temperature' => { 'Metric' => { 'Value' => 20.0 } } } }

  before do
    allow_any_instance_of(WeatherService).to receive(:current_weather).and_return(weather_data)
  end

  it 'executes successfully and fetches current weather' do
    expect(operation.success?).to be(true)
    expect(operation[:weather_data]).to eq(weather_data)
  end
end
