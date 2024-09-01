require 'rails-helper'

RSpec.describe Health::CheckOperation, type: :operation do
    subject(:operation) { described_class.call }

    it "includes 'result.success' key in options" do
        expect(operation).to include('result.success')
      end

      it "sets 'result.success' to true" do
        expect(operation['result.success']).to be(true)
      end

      it 'executes successfully' do
        expect(operation.success?).to be(true)
      end

end