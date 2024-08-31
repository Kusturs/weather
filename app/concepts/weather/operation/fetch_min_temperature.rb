# app/concepts/weather/operation/fetch_min_temperature.rb
module Weather::Operation
  class FetchMinTemperature < Trailblazer::Operation
    include WeatherHelpers

    step :fetch_data
    step :calculate_min_temperature

    def fetch_data(ctx, **)
      ctx[:data] = fetch_historical_weather
      ctx[:data].present?
    end

    def calculate_min_temperature(ctx, **)
      ctx[:min_temperature] = render_historical_min_temperature(ctx[:data])
    rescue StandardError => e
      ctx[:error] = e.message
      false
    end
  end
end
