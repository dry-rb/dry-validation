RSpec.describe Dry::Validation, 'with custom messages' do
  subject(:validation) { schema.new }

  describe 'defining schema' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        configure do |config|
          config.messages_file = SPEC_ROOT.join('fixtures/locales/en.yml')
        end

        key(:email, &:filled?)
      end
    end

    describe '#messages' do
      it 'returns compiled error messages' do
        expect(validation.(email: '').messages).to match_array([
          [:email, [['Please provide your email', '']]]
        ])
      end
    end
  end
end
