class FetchWeatherJob < Struct.new(:type)
  def perform
    service = WeatherService.new

    if type == :historical
      service.historical_weather
    else
      Rails.logger.error("Unknown job type: #{type}")
    end
  end

  def max_attempts
    3
  end

  def failure
    Rails.logger.error("FetchWeatherJob failed for type: #{type}")
  end
end
