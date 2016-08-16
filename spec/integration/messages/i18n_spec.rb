require 'dry/validation/messages/i18n'

RSpec.describe Messages::I18n do
  subject(:messages) { Messages::I18n.new }

  before do
    I18n.config.available_locales_set << :pl
    I18n.load_path.concat(%w(en pl).map { |l| SPEC_ROOT.join("fixtures/locales/#{l}.yml") })
    I18n.backend.load_translations
    I18n.locale = :pl
  end

  describe '#[]' do
    context 'with the default locale' do
      it 'returns nil when message is not defined' do
        expect(messages[:not_here, rule: :srsly]).to be(nil)
      end

      it 'returns a message for a predicate' do
        message = messages[:filled?, rule: :name]

        expect(message).to eql("nie może być pusty")
      end

      it 'returns a message for a specific rule' do
        message = messages[:filled?, rule: :email]

        expect(message).to eql("Proszę podać adres email")
      end

      it 'returns a message for a specific val type' do
        message = messages[:size?, rule: :pages, val_type: String]

        expect(message).to eql("wielkość musi być równa %{size}")
      end

      it 'returns a message for a specific rule and its default arg type' do
        message = messages[:size?, rule: :pages]

        expect(message).to eql("wielkość musi być równa %{size}")
      end

      it 'returns a message for a specific rule and its arg type' do
        message = messages[:size?, rule: :pages, arg_type: Range]

        expect(message).to eql("wielkość musi być między %{size_left} a %{size_right}")
      end
    end

    context 'with a different locale' do
      it 'returns a message for a predicate' do
        message = messages[:filled?, rule: :name, locale: :en]

        expect(message).to eql("must be filled")
      end

      it 'returns a message for a specific rule' do
        message = messages[:filled?, rule: :email, locale: :en]

        expect(message).to eql("Please provide your email")
      end

      it 'returns a message for a specific rule and its default arg type' do
        message = messages[:size?, rule: :pages, locale: :en]

        expect(message).to eql("size must be %{size}")
      end

      it 'returns a message for a specific rule and its arg type' do
        message = messages[:size?, rule: :pages, arg_type: Range, locale: :en]

        expect(message).to eql("size must be within %{size_left} - %{size_right}")
      end
    end

    context 'fallbacking to I18n.default_locale with fallback backend config' do
      before do
        require "i18n/backend/fallbacks"
        I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
      end

      it 'returns a message for a predicate in the default_locale' do
        message = messages[:even?, rule: :some_number]

        expect(I18n.locale).to eql(:pl)
        expect(message).to eql("must be even")
      end
    end
  end

  after(:all) do
    I18n.locale = I18n.default_locale
  end
end
