module Weather
  module Operation
    class FetchCurrent < Trailblazer::Operation
      step :fetch_data

      def fetch_data(ctx, **)
        weather_service = WeatherService.new
        weather_record = weather_service.fetch_weather_data_from_db_or_api

        if weather_record
          ctx[:weather_data] = weather_record
          ctx[:success] = true
        else
          ctx[:error] = 'Ошибка: Не удалось получить данные'
          ctx[:success] = false
        end
      end
    end
  end
end
