module Weather
  module Operation
    class FetchWeatherByTime < Trailblazer::Operation
      step :fetch_data

      def fetch_data(ctx, params:, **)
        weather_service = WeatherService.new
        closest_record = weather_service.fetch_weather_by_time_from_db_or_api(params[:timestamp])

        if closest_record
          ctx[:closest_temperature] = ctx[:helpers].render_weather_by_time(closest_record)
          ctx[:success] = true
        else
          ctx[:error] = 'Ошибка: Не удалось получить данные за эту дату'
          ctx[:success] = false
        end
      end
    end
  end
end
