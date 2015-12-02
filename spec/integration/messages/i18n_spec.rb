require 'dry/validation/messages/i18n'

RSpec.describe Messages::I18n do
  subject(:messages) { Messages::I18n.new }

  before do
    I18n.config.available_locales_set << :en
    I18n.locale = :en
    I18n.load_path = [SPEC_ROOT.join('fixtures/locales/en.yml')]
    I18n.backend.load_translations
  end

  describe '#lookup' do
    it 'returns a message for a predicate and its args' do
      message = messages.lookup(:eql?, [], )

      expect(message).to eql("%{name} can't be blank")
    end
  end
end
