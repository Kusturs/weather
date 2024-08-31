module Weather::Operation
  class FetchHistorical < Trailblazer::Operation
    step :fetch_historical_weather

    def fetch_historical_weather(ctx, **)
      service = WeatherService.new
      ctx[:weather_data] = service.historical_weather
    rescue StandardError => e
      ctx[:error] = e.message
      false
    end
  end
end
