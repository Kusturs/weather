require 'rails_helper'

RSpec.describe Health::CheckOperation, type: :operation do
  subject(:operation) { described_class.call }

  it 'executes successfully' do
    expect(operation.success?).to be(true)
  end
end
