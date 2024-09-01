class CreateWeatherRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :weather_records do |t|
      t.datetime :observation_time
      t.float :temperature_celsius
      t.float :temperature_fahrenheit

      t.timestamps
    end
  end
end
