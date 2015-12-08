RSpec.describe Dry::Validation do
  subject(:validation) { schema.new }

  shared_context 'schema with customized messages' do
    describe '#messages' do
      it 'returns compiled error messages' do
        expect(validation.(email: '').messages).to match_array([
          [:email, [['Please provide your email', '']]]
        ])
      end
    end
  end

  context 'yaml' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        configure do |config|
          config.messages_file = SPEC_ROOT.join('fixtures/locales/en.yml')
        end

        key(:email, &:filled?)
      end
    end

    include_context 'schema with customized messages'
  end

  context 'i18n' do
    let(:schema) do
      require 'dry/validation/messages/i18n'

      Class.new(Dry::Validation::Schema) do
        configure do |config|
          config.messages = :i18n
          config.messages_file = SPEC_ROOT.join('fixtures/locales/en.yml')
        end

        key(:email, &:filled?)
      end
    end

    include_context 'schema with customized messages'
  end
end
