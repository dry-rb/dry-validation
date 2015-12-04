require 'dry/validation/messages/i18n'

RSpec.describe Messages::I18n do
  subject(:messages) { Messages::I18n.new }

  before do
    I18n.config.available_locales_set << :en
    I18n.locale = :en
    I18n.load_path = [SPEC_ROOT.join('fixtures/locales/en.yml')]
    I18n.backend.load_translations
  end

  describe '#[]' do
    it 'returns a message for a predicate' do
      message = messages[:filled?, :name]

      expect(message).to eql("%{name} can't be blank")
    end

    it 'returns a message for a specific rule' do
      message = messages[:filled?, :email]

      expect(message).to eql("Please provide your email")
    end

    it 'returns a message for a specific rule and its default arg type' do
      message = messages[:size?, :pages, 1]

      expect(message).to eql("size must be %{num}")
    end

    it 'returns a message for a specific rule and its arg type' do
      message = messages[:size?, :pages, 1..10]

      expect(message).to eql("size must be between %{left} and %{right}")
    end
  end
end
