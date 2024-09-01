module Weather
  module Operation
    class FetchHistorical < Trailblazer::Operation
      step :fetch_data

      def fetch_data(ctx, **)
        weather_records = ctx[:helpers].fetch_historical_weather_from_db_or_api

        if weather_records.any?
          ctx[:weather_data] = weather_records
          ctx[:success] = true
        else
          ctx[:error] = 'Ошибка: Не удалось получить данные'
          ctx[:success] = false
        end
      end
    end
  end
end
