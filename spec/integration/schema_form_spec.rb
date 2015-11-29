require 'dry/validation/schema/form'

RSpec.describe Dry::Validation::Schema::Form do
  subject(:validation) { schema.new }

  describe 'defining schema' do
    let(:schema) do
      Class.new(Dry::Validation::Schema::Form) do
        key(:email) { |email| email.str? & email.filled? }

        key(:age) { |age| age.none? | (age.int? & age.gt?(18)) }
      end
    end

    describe '#messages' do
      it 'returns compiled error messages' do
        expect(validation.messages('email' => '', 'age' => '19')).to match_array([
          [:email, ["email must be filled"]]
        ])
      end
    end

    describe '#call' do
      it 'passes when attributes are valid' do
        result = validation.('email' => 'jane@doe.org', 'age' => '19')

        expect(result).to be_empty
        expect(result.params).to eql(email: 'jane@doe.org', age: 19)
      end

      it 'validates presence of an email and min age value' do
        expect(validation.('email' => '', 'age' => '18')).to match_array([
          [:error, [:input, [:age, 18, [[:val, [:age, [:predicate, [:gt?, [18]]]]]]]]],
          [:error, [:input, [:email, "", [[:val, [:email, [:predicate, [:filled?, []]]]]]]]]
        ])
      end
    end
  end
end
