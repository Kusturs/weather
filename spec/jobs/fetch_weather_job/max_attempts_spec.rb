require 'rails_helper'

RSpec.describe FetchWeatherJob, type: :job do
  subject(:job) { described_class.new(:current) }

  it 'has a maximum of 3 attempts' do
    expect(job.max_attempts).to eq(3)
  end
end
