require 'rails_helper'

RSpec.describe Health::CheckOperation do
  let(:result) { described_class.call }

  it 'is successful' do
    expect(result.success?).to be(true)
  end

  it 'sets result.success to true' do
    expect(result['result.success']).to be(true)
  end
end

