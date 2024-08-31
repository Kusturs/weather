module Request
  class API < Grape::API
    version 'v1'
    format :json
    prefix :api

    helpers do
      BASE_URL = 'http://dataservice.accuweather.com/currentconditions/v1'.freeze
      HISTORICAL_URL = 'http://dataservice.accuweather.com/currentconditions/v1'.freeze
      API_KEY = 'gBuYcaJIhWw4TSi1VsK5Ak63HQapKaNs'.freeze
      LOCATION_KEY = '28143'.freeze  # Захардкоженный ключ локации

      def fetch_weather_data(url_suffix = '')
        uri = URI("#{BASE_URL}/#{LOCATION_KEY}#{url_suffix}?apikey=#{API_KEY}")
        response = Net::HTTP.get(uri)
        JSON.parse(response)
      rescue StandardError => e
        nil
      end

      def fetch_historical_weather
        uri = URI("#{HISTORICAL_URL}/#{LOCATION_KEY}/historical/24?apikey=#{API_KEY}")
        response = Net::HTTP.get(uri)
        JSON.parse(response)
      end

      def render_current_weather(data)
        {
          temperature_celsius: data.dig('Temperature', 'Metric', 'Value'),
          temperature_fahrenheit: data.dig('Temperature', 'Imperial', 'Value')
        }
      end

      def render_historical_max_temperature(data)
        {
          max_temp_metric: data.dig('TemperatureSummary', 'Past24HourRange', 'Maximum', 'Metric', 'Value'),
          max_temp_imperial: data.dig('TemperatureSummary', 'Past24HourRange', 'Maximum', 'Imperial', 'Value')
        }
      end

      def render_historical_min_temperature(data)
        {
          min_temp_metric: data.dig('TemperatureSummary', 'Past24HourRange', 'Minimum', 'Metric', 'Value'),
          min_temp_imperial: data.dig('TemperatureSummary', 'Past24HourRange', 'Minimum', 'Imperial', 'Value')
        }
      end

      def render_historical_avg_temperature(data)
        temperatures = data.map { |d| d.dig('Temperature', 'Metric', 'Value').to_f }

        if temperatures.any?
          avg_temp_metric = (temperatures.sum / temperatures.size).round(1)
          { avg_temp_metric: avg_temp_metric }
        else
          error!('Ошибка: Нет данных для расчета средней температуры', 400)
        end
      end

      def render_weather_by_time(data, timestamp)
        closest_data = data.min_by do |d|
          (Time.parse(d['LocalObservationDateTime']).to_i - timestamp).abs
        end

        if closest_data
          {
            temperature_celsius: closest_data.dig('Temperature', 'Metric', 'Value'),
            temperature_fahrenheit: closest_data.dig('Temperature', 'Imperial', 'Value')
          }
        else
          error!('Ошибка: Нет данных для заданного времени', 404)
        end
      end

      def handle_error(e)
        error!({ error: "Ошибка: #{e.message}" }, 500)
      end
    end

    resource :weather do
      desc 'Текущая температура'
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

      desc 'Почасовая температура за последние 24 часа'
      get :historical do
        begin
          data = fetch_historical_weather

          data.map do |d|
            {
              observation_time: d['LocalObservationDateTime'],
              metric_temp: d.dig('Temperature', 'Metric', 'Value'),
              metric_unit: d.dig('Temperature', 'Metric', 'Unit'),
              imperial_temp: d.dig('Temperature', 'Imperial', 'Value'),
              imperial_unit: d.dig('Temperature', 'Imperial', 'Unit')
            }
          end
        rescue StandardError => e
          error!({error: "Не удалось получить данные: #{e.message}"}, 500)
        end
      end

      desc 'Максимальная температура за 24 часа'
      get 'historical/max' do
        response_data = fetch_historical_weather
        if response_data && response_data.any?
          render_historical_max_temperature(response_data.last)
        else
          error!('Ошибка: Не удалось получить данные о максимальной температуре', 400)
        end
      rescue => e
        handle_error(e)
      end

      desc 'Минимальная температура за 24 часа'
      get 'historical/min' do
        response_data = fetch_historical_weather
        if response_data && response_data.any?
          render_historical_min_temperature(response_data.last)
        else
          error!('Ошибка: Не удалось получить данные о минимальной температуре', 400)
        end
      rescue => e
        handle_error(e)
      end

      desc 'Средняя температура за 24 часа'
      get 'historical/avg' do
        response_data = fetch_historical_weather
        if response_data && response_data.any?
          render_historical_avg_temperature(response_data)
        else
          error!('Ошибка: Не удалось получить данные о средней температуре', 400)
        end
      rescue => e
        handle_error(e)
      end

      desc 'Температура ближайшая к заданному времени'
      params do
        requires :timestamp, type: Integer, desc: 'Временная метка (timestamp)'
      end
      get :by_time do
        timestamp = params[:timestamp]
        response_data = fetch_historical_weather
        if response_data && response_data.any?
          render_weather_by_time(response_data, timestamp)
        else
          error!('Ошибка: Не удалось получить данные для заданного времени', 400)
        end
      rescue => e
        handle_error(e)
      end
    end

    resource :health do
      desc 'Статус бекенда'
      get do
        { status: 'OK' }
      end
    end
  end
end
