require 'dry/validation/messages/i18n'

RSpec.describe Dry::Validation, 'with localized messages' do
  before do
    I18n.config.available_locales_set << :pl
    I18n.load_path.concat(%w(en pl).map { |l| SPEC_ROOT.join("fixtures/locales/#{l}.yml") })
    I18n.backend.load_translations
  end

  describe 'defining schema' do
    context 'without a namespace' do
      subject(:schema) do
        Dry::Validation.Schema do
          configure do
            config.messages = :i18n
          end

          required(:email) { |email| email.filled? }
        end
      end

      describe '#messages' do
        it 'returns localized error messages' do
          expect(schema.(email: '').messages(locale: :pl)).to eql(
            email: ['Proszę podać adres email']
          )
        end
      end
    end

    context 'with a namespace' do
      subject(:schema) do
        Dry::Validation.Schema do
          configure do
            configure do |config|
              config.messages = :i18n
              config.namespace = :user
            end
          end

          required(:email) { |email| email.filled? }
        end
      end

      describe '#messages' do
        it 'returns localized error messages' do
          expect(schema.(email: '').messages(locale: :pl)).to eql(
            email: ['Hej user! Dawaj ten email no!']
          )
        end
      end

      describe '#errors' do
        context 'with different locale' do
          before do
            I18n.locale = :pl
          end

          after do
            I18n.locale = :en
          end

          it 'contains the localized errors' do
            expect(schema.(email: '').errors).to eql(
              { email: ['Hej user! Dawaj ten email no!'] }
            )
          end
        end
      end
    end
  end
end
