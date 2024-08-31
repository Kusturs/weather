module WeatherHelpers
  BASE_URL = 'http://dataservice.accuweather.com/currentconditions/v1'.freeze
  HISTORICAL_URL = 'http://dataservice.accuweather.com/currentconditions/v1'.freeze
  API_KEY = 'gBuYcaJIhWw4TSi1VsK5Ak63HQapKaNs'.freeze
  LOCATION_KEY = '28143'.freeze

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

  def render_current_weather(data)
    {
      temperature_celsius: data.dig('Temperature', 'Metric', 'Value'),
      temperature_fahrenheit: data.dig('Temperature', 'Imperial', 'Value')
    }
  end

  def render_historical_max_temperature(data)
    max_temp_data = data.max_by { |d| d.dig('Temperature', 'Metric', 'Value') }
    {
      max_temp_metric: max_temp_data.dig('Temperature', 'Metric', 'Value'),
      max_temp_imperial: max_temp_data.dig('Temperature', 'Imperial', 'Value'),
      time: max_temp_data['LocalObservationDateTime']
    }
  end

  def render_historical_min_temperature(data)
    min_temp_data = data.min_by { |d| d.dig('Temperature', 'Metric', 'Value') }
    {
      min_temp_metric: min_temp_data.dig('Temperature', 'Metric', 'Value'),
      min_temp_imperial: min_temp_data.dig('Temperature', 'Imperial', 'Value'),
      time: min_temp_data['LocalObservationDateTime']
    }
  end

  def render_historical_avg_temperature(data)
    temperatures = data.map { |d| d.dig('Temperature', 'Metric', 'Value').to_f }

    if temperatures.any?
      avg_temp_metric = (temperatures.sum / temperatures.size).round(1)
      { avg_temp_metric: avg_temp_metric }
    else
      error!('Ошибка: Нет данных для расчета средней температуры', 400)
    end
  end

  def render_weather_by_time(data, timestamp)
    closest_data = data.min_by do |d|
      (Time.parse(d['LocalObservationDateTime']).to_i - timestamp).abs
    end

    if closest_data
      {
        temperature_celsius: closest_data.dig('Temperature', 'Metric', 'Value'),
        temperature_fahrenheit: closest_data.dig('Temperature', 'Imperial', 'Value')
      }
    else
      error!('Ошибка: Нет данных для заданного времени', 404)
    end
  end

  def handle_error(e)
    error!({ error: "Ошибка: #{e.message}" }, 500)
  end
end
