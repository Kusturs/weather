module Request
  class API < Grape::API
    version 'v1'
    format :json
    prefix :api

    helpers do
      BASE_URL = 'http://dataservice.accuweather.com/currentconditions/v1'.freeze
      API_KEY = 'NHNnB2MAyFTXjmkQr8Q2vSLSqWxljC2A'.freeze
      LOCATION_KEY = '28143'.freeze

      def fetch_weather_data
        uri = URI("#{BASE_URL}/#{LOCATION_KEY}?apikey=#{API_KEY}")
        response = Net::HTTP.get(uri)
        JSON.parse(response)
      rescue StandardError => e
        nil
      end

      def render_current_weather(data)
        {
          temperature: data['Temperature']['Metric']['Value'],
          unit: data['Temperature']['Metric']['Unit'],
          weather_text: data['WeatherText']
        }
      end

      def handle_error(e)
        error!({ error: "Ошибка: #{e.message}" }, 500)
      end
    end

    resource :weather do
      desc 'Получить текущую температуру'
      get :current do
        response_data = fetch_weather_data

        if response_data && response_data.any?
          render_current_weather(response_data.first)
        else
          error!('Ошибка: Не удалось получить данные о текущей температуре', 400)
        end
      rescue => e
        handle_error(e)
      end
    end
  end
end
