RSpec.describe Dry::Validation, 'with custom messages' do
  subject(:validation) { schema.new }

  describe 'defining schema' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        configure do |config|
          config.messages_file = SPEC_ROOT.join('fixtures/errors.yml')
          config.namespace = :user
        end

        key(:email) { |email| email.filled? }
      end
    end

    let(:attrs) do
      {
        email: 'jane@doe.org',
        age: 19,
        address: { city: 'NYC', street: 'Street 1/2', country: { code: 'US', name: 'USA' } },
        phone_numbers: [
          '123456', '234567'
        ]
      }.freeze
    end

    describe '#messages' do
      it 'returns compiled error messages' do
        expect(validation.messages(attrs.merge(email: ''))).to match_array([
          [:email, ["email can't be blank"]]
        ])
      end
    end
  end
end
