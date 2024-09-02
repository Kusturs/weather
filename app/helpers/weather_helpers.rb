module WeatherHelpers
  BASE_URL = 'http://dataservice.accuweather.com/currentconditions/v1'.freeze
  HISTORICAL_URL = 'http://dataservice.accuweather.com/currentconditions/v1'.freeze
  API_KEY = ENV['ACCUWEATHER_API_KEY'].freeze
  LOCATION_KEY = ENV['LOCATION_KEY'].freeze

  def fetch_weather_data(url_suffix = '')
    uri = URI("#{BASE_URL}/#{LOCATION_KEY}#{url_suffix}?apikey=#{API_KEY}")
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  rescue StandardError => e
    nil
  end

  def fetch_historical_weather
    uri = URI("#{HISTORICAL_URL}/#{LOCATION_KEY}/historical/24?apikey=#{API_KEY}")
    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  def render_current_weather(record)
    {
      temperature_celsius: record.temperature_celsius,
      temperature_fahrenheit: record.temperature_fahrenheit
    }
  end

  def render_historical_max_temperature(records)
    max_record = records.max_by(&:temperature_celsius)
    {
      max_temp_metric: max_record.temperature_celsius,
      max_temp_imperial: max_record.temperature_fahrenheit,
      time: max_record.observation_time
    }
  end


  def render_historical_min_temperature(records)
    min_record = records.min_by(&:temperature_celsius)
    {
      min_temp_metric: min_record.temperature_celsius,
      min_temp_imperial: min_record.temperature_fahrenheit,
      time: min_record.observation_time
    }
  end

  def render_historical_avg_temperature(records)
    temperatures = records.map(&:temperature_celsius)

    if temperatures.any?
      avg_temp_metric = (temperatures.sum / temperatures.size).round(1)
      { avg_temp_metric: avg_temp_metric }
    else
      raise 'Ошибка: Нет данных для расчета средней температуры'
    end
  end

  def render_weather_by_time(record)
    {
      temperature_celsius: record.temperature_celsius,
      temperature_fahrenheit: record.temperature_fahrenheit
    }
  end

  private

  def recent_data?(observation_time)
    observation_time >= 1.hour.ago
  end

  def save_weather_data(data)
    weather_data = data.first

    WeatherRecord.create(
      observation_time: Time.parse(weather_data["LocalObservationDateTime"]),
      temperature_celsius: weather_data["Temperature"]["Metric"]["Value"],
      temperature_fahrenheit: weather_data["Temperature"]["Imperial"]["Value"],
      )
  end

  def save_historical_weather_data(data)
    data.each do |d|
      HistoricalWeatherRecord.create!(
        observation_time: Time.parse(d["LocalObservationDateTime"]),
        temperature_celsius: d["Temperature"]["Metric"]["Value"],
        temperature_fahrenheit: d["Temperature"]["Imperial"]["Value"],
      )
    end
  end
  
  def handle_error(e)
    Rails.logger.error("Ошибка: #{e.message}")
    error!({ error: "Ошибка: #{e.message}" }, 500)
  end
end
