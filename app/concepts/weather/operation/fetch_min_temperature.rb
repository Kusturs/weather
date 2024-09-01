module Weather
  module Operation
    class FetchMinTemperature < Trailblazer::Operation
      step :fetch_data

      def fetch_data(ctx, **)
        min_record = ctx[:helpers].fetch_min_temperature_from_db_or_api

        if min_record
          ctx[:min_temperature] = ctx[:helpers].render_historical_min_temperature([min_record])
          ctx[:success] = true
        else
          ctx[:error] = 'Ошибка: Не удалось получить данные'
          ctx[:success] = false
        end
      end
    end
  end
end
