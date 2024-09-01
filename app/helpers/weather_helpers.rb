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

  def fetch_weather_data_from_db_or_api(url_suffix = '')
    latest_record = WeatherRecord.order(observation_time: :desc).first

    if latest_record && recent_data?(latest_record.observation_time)
      latest_record
    else
      data = fetch_weather_data(url_suffix)
      save_weather_data(data)
      WeatherRecord.order(observation_time: :desc).first
    end
  end

  def fetch_historical_weather_from_db_or_api
    latest_records = WeatherRecord.where('observation_time >= ?', 24.hours.ago).order(observation_time: :asc)

    if latest_records.exists?
      latest_records
    else
      data = fetch_historical_weather
      save_historical_weather_data(data)
      WeatherRecord.where('observation_time >= ?', 24.hours.ago).order(observation_time: :asc)
    end
  end

  def fetch_max_temperature_from_db_or_api
    max_record = WeatherRecord.where('observation_time >= ?', 24.hours.ago).order(temperature_celsius: :desc).first

    if max_record
      max_record
    else
      data = fetch_historical_weather
      save_historical_weather_data(data)
      WeatherRecord.where('observation_time >= ?', 24.hours.ago).order(temperature_celsius: :desc).first
    end
  end

  def fetch_min_temperature_from_db_or_api
    min_record = WeatherRecord.where('observation_time >= ?', 24.hours.ago).order(temperature_celsius: :asc).first

    if min_record
      min_record
    else
      data = fetch_historical_weather
      save_historical_weather_data(data)
      WeatherRecord.where('observation_time >= ?', 24.hours.ago).order(temperature_celsius: :asc).first
    end
  end

  def fetch_avg_temperature_from_db_or_api
    records = WeatherRecord.where('observation_time >= ?', 24.hours.ago)

    if records.exists?
      temperatures = records.map(&:temperature_celsius)
      avg_temperature = temperatures.sum / temperatures.size if temperatures.any?
      avg_temperature
    else
      data = fetch_historical_weather
      save_historical_weather_data(data)
      temperatures = WeatherRecord.where('observation_time >= ?', 24.hours.ago).map(&:temperature_celsius)
      temperatures.sum / temperatures.size if temperatures.any?
    end
  end

  def fetch_weather_by_time_from_db_or_api(timestamp)
    closest_record = WeatherRecord
                       .select("*, ABS(EXTRACT(EPOCH FROM observation_time) - #{timestamp}) AS time_diff")
                       .order("time_diff")
                       .first
    if closest_record
      closest_record
    else
      data = fetch_historical_weather
      save_historical_weather_data(data)
      WeatherRecord
        .select("*, ABS(EXTRACT(EPOCH FROM observation_time) - #{timestamp}) AS time_diff")
        .order("time_diff")
        .first
    end
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
      WeatherRecord.create!(
        observation_time: d['LocalObservationDateTime'],
        temperature_celsius: d.dig('Temperature', 'Metric', 'Value'),
        temperature_fahrenheit: d.dig('Temperature', 'Imperial', 'Value')
      )
    end
  end

  def handle_error(e)
    Rails.logger.error("Ошибка: #{e.message}")
    error!({ error: "Ошибка: #{e.message}" }, 500)
  end
end
