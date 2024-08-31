module Request
  class API < Grape::API
    version 'v1'
    format :json
    prefix :api

    helpers WeatherHelpers  # Включаем WeatherHelpers

    before do
      @weather_service = WeatherService.new  # Инициализируем WeatherService перед каждым запросом
    end

    resource :weather do
      desc 'Текущая температура'
      get :current do
        response_data = @weather_service.current_weather

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
        data = @weather_service.historical_weather

        if data && data.any?
          data.map do |d|
            {
              observation_time: d['LocalObservationDateTime'],
              metric_temp: d.dig('Temperature', 'Metric', 'Value'),
              metric_unit: d.dig('Temperature', 'Metric', 'Unit'),
              imperial_temp: d.dig('Temperature', 'Imperial', 'Value'),
              imperial_unit: d.dig('Temperature', 'Imperial', 'Unit')
            }
          end
        else
          error!('Ошибка: Не удалось получить исторические данные о погоде', 400)
        end
      rescue => e
        handle_error(e)
      end

      desc 'Максимальная температура за 24 часа'
      get 'historical/max' do
        response_data = @weather_service.historical_weather
        if response_data && response_data.any?
          render_historical_max_temperature(response_data)
        else
          error!('Ошибка: Не удалось получить данные о максимальной температуре', 400)
        end
      rescue => e
        handle_error(e)
      end

      desc 'Минимальная температура за 24 часа'
      get 'historical/min' do
        response_data = @weather_service.historical_weather
        if response_data && response_data.any?
          render_historical_min_temperature(response_data)
        else
          error!('Ошибка: Не удалось получить данные о минимальной температуре', 400)
        end
      rescue => e
        handle_error(e)
      end

      desc 'Средняя температура за 24 часа'
      get 'historical/avg' do
        response_data = @weather_service.historical_weather
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
        response_data = @weather_service.historical_weather
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




