module Weather::Operation
  class FetchWeatherByTime < Trailblazer::Operation
    include WeatherHelpers

    step :fetch_data
    step :find_closest_temperature

    def fetch_data(ctx, params:, **)
      ctx[:data] = fetch_historical_weather
      ctx[:data].present?
    end

    def find_closest_temperature(ctx, params:, **)
      timestamp = params[:timestamp]

      ctx[:closest_temperature] = render_weather_by_time(ctx[:data], timestamp)
    rescue StandardError => e
      ctx[:error] = e.message
      false
    end
  end
end
