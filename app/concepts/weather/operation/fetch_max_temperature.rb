module Weather::Operation
  class FetchMaxTemperature < Trailblazer::Operation
    include WeatherHelpers

    step :fetch_data
    step :calculate_max_temperature

    def fetch_data(ctx, **)
      ctx[:data] = fetch_historical_weather
      ctx[:data].present?
    end

    def calculate_max_temperature(ctx, **)
      ctx[:max_temperature] = render_historical_max_temperature(ctx[:data])
    rescue StandardError => e
      ctx[:error] = e.message
      false
    end
  end
end
