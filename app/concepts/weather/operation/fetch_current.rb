module Weather::Operation
  class FetchCurrent < Trailblazer::Operation
    step :fetch_current_weather

    def fetch_current_weather(ctx, **)
      service = WeatherService.new
      ctx[:weather_data] = service.current_weather
    rescue StandardError => e
      ctx[:error] = e.message
      false
    end
  end
end
