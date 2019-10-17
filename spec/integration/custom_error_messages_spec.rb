require 'dry/validation/messages/i18n'

RSpec.describe Dry::Validation do
  shared_context 'schema with customized messages' do
    describe '#messages' do
      it 'returns compiled error messages' do
        expect(schema.(email: '', age: 12).messages).to eql(
          email: ['Please provide your email'], age: ['12 must be greater than 18']
        )

        expect(schema.(email: '', age: 14).messages).to eql(
          email: ['Please provide your email'], age: ['14 must be greater than 18']
        )
      end
    end
  end

  context 'yaml' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          config.messages_file = SPEC_ROOT.join('fixtures/locales/en.yml')
        end

        required(:email).filled
        required(:age).value(gt?: 18)
      end
    end

    include_context 'schema with customized messages'
  end

  context 'i18n' do
    context 'with custom messages set globally' do
      before do
        I18n.load_path << SPEC_ROOT.join('fixtures/locales/en.yml')
        I18n.backend.load_translations
      end

      subject(:schema) do
        Dry::Validation.Schema do
          configure do
            config.messages = :i18n
          end

          required(:email).filled
          required(:age).value(gt?: 18)
        end
      end

      include_context 'schema with customized messages'
    end
  end
end
