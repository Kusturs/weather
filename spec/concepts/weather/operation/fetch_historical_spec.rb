require 'rails_helper'

RSpec.describe Weather::Operation::FetchHistorical, type: :operation do
  subject(:operation) { described_class.call }

  context 'when historical weather data is available' do 
    let(:weather_data) do
        [
          { 'Temperature' => { 'Metric' => { 'Value' => 20.0 } } },
          { 'Temperature' => { 'Metric' => { 'Value' => 22.0 } } }
        ]
      end
    
      before do
        allow_any_instance_of(WeatherService).to receive(:historical_weather).and_return(weather_data)
      end
    
      it 'executes successfully and fetches historical weather data' do
        expect(operation.success?).to be(true)
        expect(operation[:weather_data]).to eq(weather_data)
      end
  end 

  context 'when historical weather data is empty' do 
    before do
        allow_any_instance_of(WeatherService).to receive(:historical_weather).and_return(nil)
      end
    
      it 'handles empty response from weather service' do
        expect(operation[:weather_data]).to be_nil
      end
  end

  context 'when an error occurs during historical weather data fetch' do 
    before do
        allow_any_instance_of(WeatherService).to receive(:historical_weather).and_raise(StandardError, 'Service unavailable')
      end
    
      it 'handles error during historical weather data fetch' do
        expect(operation.success?).to be(false)
        expect(operation[:error]).to eq('Service unavailable')
      end
  end

end