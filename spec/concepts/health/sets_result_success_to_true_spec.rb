require 'rails_helper'

RSpec.describe Health::CheckOperation, type: :operation do
  subject(:operation) { described_class.call }

  it "sets 'result.success' to true" do
    expect(operation['result.success']).to be(true)
  end
end
