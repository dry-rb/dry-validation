RSpec.describe Dry::Validation, 'with localized messages' do
  subject(:validation) { schema.new }

  before do
    I18n.config.available_locales_set << :en << :pl
    I18n.locale = :en
    I18n.load_path = %w(en pl).map { |l| SPEC_ROOT.join("fixtures/locales/#{l}.yml") }
    I18n.backend.load_translations
  end

  describe 'defining schema' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        configure do |config|
          config.messages = Dry::Validation::Messages::I18n.new
        end

        key(:email) { |email| email.filled? }
      end
    end

    describe '#messages' do
      it 'returns localized error messages' do
        expect(validation.(email: '').messages(locale: :pl)).to match_array([
          [:email, ["Proszę podać adres email"]]
        ])
      end
    end
  end
end
