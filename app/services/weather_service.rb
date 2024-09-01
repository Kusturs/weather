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

  def fetch_historical_weather_async
    Delayed::Job.enqueue FetchWeatherJob.new(:historical)
  end
end
