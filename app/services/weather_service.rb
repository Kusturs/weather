class WeatherService
  include WeatherHelpers

  def initialize
  end

  def current_weather
    fetch_weather_data
  end

  def historical_weather
    fetch_historical_weather
  end
end
