module Weather
  module Operation
    class FetchCurrent < Trailblazer::Operation
      step :fetch_data

      def fetch_data(ctx, **)
        weather_record = ctx[:helpers].fetch_weather_data_from_db_or_api

        Rails.logger.info(weather_record)
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
