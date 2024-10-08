require 'rufus-scheduler'

scheduler = Rufus::Scheduler.new

scheduler.every '1h' do
  WeatherService.new.fetch_historical_weather_async
end

scheduler_thread = Thread.new { scheduler.join }
