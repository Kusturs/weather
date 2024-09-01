module Weather
  module Operation
    class FetchMaxTemperature < Trailblazer::Operation
      step :fetch_data

      def fetch_data(ctx, **)
        max_record = ctx[:helpers].fetch_max_temperature_from_db_or_api

        if max_record
          ctx[:max_temperature] = ctx[:helpers].render_historical_max_temperature([max_record])
          ctx[:success] = true
        else
          ctx[:error] = 'Ошибка: Не удалось получить данные'
          ctx[:success] = false
        end
      end
    end
  end
end
