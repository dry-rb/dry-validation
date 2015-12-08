require 'dry/validation/messages/i18n'

RSpec.describe Messages::I18n do
  subject(:messages) { Messages::I18n.new }

  before do
    I18n.config.available_locales_set << :pl
    I18n.load_path.concat(%w(en pl).map { |l| SPEC_ROOT.join("fixtures/locales/#{l}.yml") })
    I18n.backend.load_translations
  end

  describe '#[]' do
    context 'with the default locale' do
      it 'returns a message for a predicate' do
        message = messages[:filled?, rule: :name]

        expect(message).to eql("%{name} must be filled")
      end

      it 'returns a message for a specific rule' do
        message = messages[:filled?, rule: :email]

        expect(message).to eql("Please provide your email")
      end

      it 'returns a message for a specific val type' do
        message = messages[:size?, rule: :pages, val_type: String]

        expect(message).to eql("%{name} length must be %{num}")
      end

      it 'returns a message for a specific rule and its default arg type' do
        message = messages[:size?, rule: :pages]

        expect(message).to eql("%{name} size must be %{num}")
      end

      it 'returns a message for a specific rule and its arg type' do
        message = messages[:size?, rule: :pages, arg_type: Range]

        expect(message).to eql("%{name} size must be within %{left} - %{right}")
      end
    end

    context 'with a different locale' do
      it 'returns a message for a predicate' do
        message = messages[:filled?, rule: :name, locale: :pl]

        expect(message).to eql("%{name} nie może być pusty")
      end

      it 'returns a message for a specific rule' do
        message = messages[:filled?, rule: :email, locale: :pl]

        expect(message).to eql("Proszę podać adres email")
      end

      it 'returns a message for a specific rule and its default arg type' do
        message = messages[:size?, rule: :pages, locale: :pl]

        expect(message).to eql("wielkość musi być równa %{num}")
      end

      it 'returns a message for a specific rule and its arg type' do
        message = messages[:size?, rule: :pages, arg_type: Range, locale: :pl]

        expect(message).to eql("wielkość musi być między %{left} a %{right}")
      end
    end
  end
end
