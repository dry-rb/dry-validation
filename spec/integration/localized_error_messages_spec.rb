require 'dry/validation/messages/i18n'

RSpec.describe Dry::Validation, 'with localized messages' do
  subject(:validation) { schema.new }

  before do
    I18n.config.available_locales_set << :pl
    I18n.load_path.concat(%w(en pl).map { |l| SPEC_ROOT.join("fixtures/locales/#{l}.yml") })
    I18n.backend.load_translations
  end

  describe 'defining schema' do
    context 'without a namespace' do
      let(:schema) do
        Class.new(Dry::Validation::Schema) do
          configure do |config|
            config.messages = :i18n
          end

          key(:email) { |email| email.filled? }
        end
      end

      describe '#messages' do
        it 'returns localized error messages' do
          expect(validation.(email: '').messages(locale: :pl)).to match_array([
            [:email, [['Proszę podać adres email'], '']]
          ])
        end
      end
    end

    context 'with a namespace' do
      let(:schema) do
        Class.new(Dry::Validation::Schema) do
          configure do |config|
            config.messages = :i18n
            config.namespace = :user
          end

          key(:email) { |email| email.filled? }
        end
      end

      describe '#messages' do
        it 'returns localized error messages' do
          expect(validation.(email: '').messages(locale: :pl)).to match_array([
            [:email, [['Hej user! Dawaj ten email no!'], '']]
          ])
        end
      end
    end
  end
end
