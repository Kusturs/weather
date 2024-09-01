require 'rails_helper'

RSpec.describe Weather::Operation::FetchMaxTemperature, type: :operation do
  subject(:operation) { described_class.call }

  context 'when weather data is available' do 
    let(:data) do
        [
          { 'Temperature' => { 'Metric' => { 'Value' => 15.0 } } },
          { 'Temperature' => { 'Metric' => { 'Value' => 25.0 } } }
        ]
      end
    
      before do
        allow_any_instance_of(Weather::Operation::FetchMaxTemperature).to receive(:fetch_historical_weather).and_return(data)
        allow_any_instance_of(Weather::Operation::FetchMaxTemperature).to receive(:render_historical_max_temperature).and_return(25.0)
      end
    
      it 'executes successfully and calculates max temperature' do
        expect(operation.success?).to be(true)
        expect(operation[:max_temperature]).to eq(25.0)
      end
  end

  context 'when weather data is empty' do 
    before do
        allow_any_instance_of(Weather::Operation::FetchMaxTemperature).to receive(:fetch_historical_weather).and_return(nil)
      end
    
      it 'handles empty data correctly' do
        expect(operation.success?).to be(false)
        expect(operation[:data]).to be_nil
      end
  end

  context 'when an error occurs during calculating max temperature' do
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

end
