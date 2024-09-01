require 'rails_helper'

RSpec.describe FetchWeatherJob, type: :job do
  subject(:job) { described_class.new(:historical) }

  it 'calls perform with historical type' do
    expect(job.type).to eq(:historical)
    expect {
      job.perform
    }.to_not raise_error
  end
end
