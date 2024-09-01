require 'rails_helper'

RSpec.describe Health::CheckOperation, type: :operation do
  subject(:operation) { described_class.call }

  it "includes 'result.success' key in options" do
    expect(operation).to include('result.success')
  end
end
