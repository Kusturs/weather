class WeatherService
  include WeatherHelpers

  def initialize
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
    latest_records = HistoricalWeatherRecord.where('observation_time >= ?', 24.hours.ago).order(observation_time: :asc)

    if latest_records.exists?
      latest_records
    else
      data = fetch_historical_weather
      save_historical_weather_data(data)
      HistoricalWeatherRecord.where('observation_time >= ?', 24.hours.ago).order(observation_time: :asc)
    end
  end

  def fetch_max_temperature_from_db_or_api
    max_record = HistoricalWeatherRecord.where('observation_time >= ?', 24.hours.ago).order(temperature_celsius: :desc).first

    if max_record
      max_record
    else
      data = fetch_historical_weather
      save_historical_weather_data(data)
      HistoricalWeatherRecord.where('observation_time >= ?', 24.hours.ago).order(temperature_celsius: :desc).first
    end
  end

  def fetch_min_temperature_from_db_or_api
    min_record = HistoricalWeatherRecord.where('observation_time >= ?', 24.hours.ago).order(temperature_celsius: :asc).first

    if min_record
      min_record
    else
      data = fetch_historical_weather
      save_historical_weather_data(data)
      HistoricalWeatherRecord.where('observation_time >= ?', 24.hours.ago).order(temperature_celsius: :asc).first
    end
  end

  def fetch_avg_temperature_from_db_or_api
    records = HistoricalWeatherRecord.where('observation_time >= ?', 24.hours.ago)

    if records.exists?
      temperatures = records.map(&:temperature_celsius)
      avg_temperature = temperatures.sum / temperatures.size if temperatures.any?
      avg_temperature
    else
      data = fetch_historical_weather
      save_historical_weather_data(data)
      temperatures = HistoricalWeatherRecord.where('observation_time >= ?', 24.hours.ago).map(&:temperature_celsius)
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

  def historical_weather
    fetch_historical_weather
  end

  def fetch_historical_weather_async
    Delayed::Job.enqueue FetchWeatherJob.new(:historical)
  end
end
