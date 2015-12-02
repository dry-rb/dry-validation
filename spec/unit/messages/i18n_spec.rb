require 'dry/validation/messages/i18n'

RSpec.describe Messages::I18n do
  subject(:messages) { Messages::I18n.new }

  describe '#lookup' do
    it 'returns a message for a predicate and its args' do
      pending

      message = messages.lookup(:eql?, [], )

      expect(message).to eql("%{name} can't be blank")
    end
  end
end
