module Weather
  module Operation
    class FetchAvgTemperature < Trailblazer::Operation
      step :fetch_data

      def fetch_data(ctx, **)
        avg_temperature = ctx[:helpers].fetch_avg_temperature_from_db_or_api

        if avg_temperature
          ctx[:avg_temperature] = { avg_temp_metric: avg_temperature }
          ctx[:success] = true
        else
          ctx[:error] = 'Ошибка: Не удалось получить данные'
          ctx[:success] = false
        end
      end
    end
  end
end
