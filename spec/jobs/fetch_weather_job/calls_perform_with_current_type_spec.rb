require 'rails_helper'

RSpec.describe FetchWeatherJob, type: :job do
  subject(:job) { described_class.new(:current) }

  it 'calls perform with current type' do
    expect(job.type).to eq(:current)
    expect {
      job.perform
    }.to_not raise_error
  end
end
