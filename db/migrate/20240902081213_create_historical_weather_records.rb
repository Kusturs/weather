class CreateHistoricalWeatherRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :historical_weather_records do |t|
      t.datetime :observation_time, null: false
      t.float :temperature_celsius, null: false
      t.float :temperature_fahrenheit, null: false

      t.timestamps
    end

    add_index :historical_weather_records, :observation_time, unique: true
  end
end
