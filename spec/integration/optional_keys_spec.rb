RSpec.describe Dry::Validation::Schema do
  subject(:validation) { schema.new }

  describe 'defining schema with optional keys' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        optional(:email) { |email| email.filled? }
      end
    end

    describe '#call' do
      it 'skips rules when key is not present' do
        expect(validation.({})).to be_empty
      end

      it 'applies rules when key is present' do
        expect(validation.(email: '')).to_not be_empty
      end
    end
  end
end
