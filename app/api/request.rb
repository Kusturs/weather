module Request
  class API < Grape::API
    version 'v1'
    format :json
    prefix :api

    helpers WeatherHelpers

    before do
      @weather_service = WeatherService.new
    end

    resource :weather do
      desc 'Текущая температура'
      get :current do
        result = Weather::Operation::FetchCurrent.call(helpers: self)

        if result[:success]
          render_current_weather(result[:weather_data])
        else
          error!(result[:error], 400)
        end
      rescue => e
        handle_error(e)
      end

      desc 'Почасовая температура за последние 24 часа'
      get :historical do
        result = Weather::Operation::FetchHistorical.call(helpers: self)

        if result[:success]
          result[:weather_data].map do |d|
            {
              observation_time: d.observation_time,
              metric_temp: d.temperature_celsius,
              imperial_temp: d.temperature_fahrenheit
            }
          end
        else
          error!(result[:error], 400)
        end
      rescue => e
        handle_error(e)
      end

      desc 'Максимальная температура за 24 часа'
      get 'historical/max' do
        result = Weather::Operation::FetchMaxTemperature.call(helpers: self)

        if result[:success]
          result[:max_temperature]
        else
          error!(result[:error] || 'Ошибка: Не удалось получить данные о максимальной температуре', 400)
        end
      rescue => e
        handle_error(e)
      end

      desc 'Минимальная температура за 24 часа'
      get 'historical/min' do
        result = Weather::Operation::FetchMinTemperature.call(helpers: self)

        if result[:success]
          result[:min_temperature]
        else
          error!(result[:error], 400)
        end
      rescue => e
        handle_error(e)
      end

      desc 'Средняя температура за 24 часа'
      get 'historical/avg' do
        result = Weather::Operation::FetchAvgTemperature.call(helpers: self)

        if result[:success]
          result[:avg_temperature]
        else
          error!(result[:error], 400)
        end
      rescue => e
        handle_error(e)
      end

      desc 'Температура ближайшая к заданному времени'
      params do
        requires :timestamp, type: Integer, desc: 'Временная метка (timestamp)'
      end
      get 'by_time' do
        result = Weather::Operation::FetchWeatherByTime.call(params: params, helpers: self)

        if result[:success]
          result[:closest_temperature]
        else
          error!(result[:error], 400)
        end
      rescue => e
        handle_error(e)
      end
    end

    resource :health do
      desc 'Статус бекенда'
      get do
        result = Health::CheckOperation.call

        if result.success?
          { status: 'OK' }
        else
          error!('Internal server error', 500)
        end
      end
    end
  end
end
