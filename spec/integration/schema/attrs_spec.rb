require 'ostruct'

RSpec.describe Schema, 'defining schema with attrs' do
  subject(:validation) { schema.new }

  let(:schema) do
    Class.new(Dry::Validation::Schema) do
      attr(:email) { |email| email.filled? }

      attr(:address) do |address|
        address.attr(:city, &:filled?)
        address.attr(:street, &:filled?)
      end
    end
  end

  describe '#call' do
    context 'when valid input' do
      let(:input) do
        struct_from_hash(email: "email@test.com", address: { city: 'NYC', street: 'Street 1/2' })
      end

      it 'should be valid' do
        expect(validation.(input)).to be_empty
      end
    end

    context 'when input does not have proper attributes' do
      let(:input) do
        struct_from_hash(name: "John", address: { country: 'US', street: 'Street 1/2' })
      end

      it 'should not be valid' do
        expect(validation.(input)).to_not be_empty
      end
    end
  end
end
