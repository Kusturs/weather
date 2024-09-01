require 'rails_helper'

RSpec.describe Weather::Operation::StatusBackend, type: :operation do
  it 'calls check_status' do
    expect_any_instance_of(Weather::Operation::StatusBackend).to receive(:check_status)
    described_class.call
  end
end