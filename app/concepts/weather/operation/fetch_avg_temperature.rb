module Weather::Operation
  class FetchAvgTemperature < Trailblazer::Operation
    step :fetch_historical_weather
    step :calculate_avg_temperature

    def fetch_historical_weather(ctx, **)
      service = WeatherService.new
      ctx[:weather_data] = service.historical_weather
    rescue StandardError => e
      ctx[:error] = e.message
      false
    end

    def calculate_avg_temperature(ctx, **)
      data = ctx[:weather_data]
      temperatures = data.map { |d| d.dig('Temperature', 'Metric', 'Value').to_f }
      ctx[:avg_temperature] = (temperatures.sum / temperatures.size).round(1) if temperatures.any?
    end
  end
end
