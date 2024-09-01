require 'rails_helper'

RSpec.describe Weather::Operation::FetchCurrent, type: :operation do
  subject(:operation) { described_class.call }

    context 'when current weather data is available' do 
        let(:weather_data) { { 'Temperature' => { 'Metric' => { 'Value' => 20.0 } } } }

        before do
            allow_any_instance_of(WeatherService).to receive(:current_weather).and_return(weather_data)
        end

        it 'executes successfully and fetches current weather' do
            expect(operation.success?).to be(true)
            expect(operation[:weather_data]).to eq(weather_data)
        end
    end

    context 'when current weather data is empty' do 
        before do
            allow_any_instance_of(WeatherService).to receive(:current_weather).and_return(nil)
          end
        
          it 'handles empty response from weather service' do
            expect(operation[:weather_data]).to be_nil
          end
    end

    context 'when an error occurs during current weather data fetch' do
        before do
            allow_any_instance_of(WeatherService).to receive(:current_weather).and_raise(StandardError, 'Service unavailable')
          end
        
          it 'handles error during current weather data fetch' do
            expect(operation.success?).to be(false)
            expect(operation[:error]).to eq('Service unavailable')
          end
    end 

end 
