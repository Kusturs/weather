class FetchWeatherJob < Struct.new(:type)
  def perform
    service = WeatherService.new
    case type
    when :current
      service.current_weather
    when :historical
      service.historical_weather
    end
  end

  def max_attempts
    3
  end

  def failure
    Rails.logger.error("FetchWeatherJob failed for type: #{type}")
  end
end