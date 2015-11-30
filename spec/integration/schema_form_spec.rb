require 'dry/validation/schema/form'

RSpec.describe Dry::Validation::Schema::Form do
  subject(:validation) { schema.new }

  describe 'defining schema' do
    let(:schema) do
      Class.new(Dry::Validation::Schema::Form) do
        key(:email) { |email| email.filled? }

        key(:age) { |age| age.none? | (age.int? & age.gt?(18)) }

        key(:address) do |address|
          address.hash? do
            address.key(:city, &:filled?)
            address.key(:street, &:filled?)

            address.key(:loc) do |loc|
              loc.key(:lat) { |lat| lat.filled? & lat.float? }
              loc.key(:lng) { |lng| lng.filled? & lng.float? }
            end
          end
        end
      end
    end

    describe '#messages' do
      it 'returns compiled error messages' do
        expect(validation.messages('email' => '', 'age' => '19')).to match_array([
          [:email, ["email must be filled"]],
          [:address, ["address is missing"]]
        ])
      end
    end

    describe '#call' do
      it 'passes when attributes are valid' do
        result = validation.(
          'email' => 'jane@doe.org',
          'age' => '19',
          'address' => {
            'city' => 'NYC',
            'street' => 'Street 1/2',
            'loc' => { 'lat' => '123.456', 'lng' => '456.123' }
          }
        )

        expect(result).to be_empty

        expect(result.params).to eql(
          email: 'jane@doe.org', age: 19,
          address: {
            city: 'NYC', street: 'Street 1/2',
            loc: { lat: 123.456, lng: 456.123 }
          }
        )
      end

      it 'validates presence of an email and min age value' do
        expect(validation.('email' => '', 'age' => '18')).to match_array([
          [:error, [:input, [:age, 18, [[:val, [:age, [:predicate, [:gt?, [18]]]]]]]]],
          [:error, [:input, [:email, "", [[:val, [:email, [:predicate, [:filled?, []]]]]]]]],
          [:error, [:input, [:address, nil, [[:key, [:address, [:predicate, [:key?, [:address]]]]]]]]]
        ])
      end
    end
  end
end
