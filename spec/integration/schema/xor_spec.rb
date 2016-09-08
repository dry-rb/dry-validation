RSpec.describe 'Schema with xor rules' do
  subject(:schema) do
    Dry::Validation.Schema do
      configure do
        def self.messages
          Messages.default.merge(
            en: { errors: { be_reasonable: 'you cannot eat cake and have cake!' } }
          )
        end
      end

      required(:eat_cake).filled

      required(:have_cake).filled

      rule(be_reasonable: %i[eat_cake have_cake]) do |ec, hc|
        ec.eql?('yes!') ^ hc.eql?('yes!')
      end
    end
  end

  describe '#messages' do
    it 'passes when only one option is selected' do
      messages = schema.(eat_cake: 'yes!', have_cake: 'no!').messages[:be_reasonable]

      expect(messages).to be(nil)
    end

    it 'fails when both options are selected' do
      expect(schema.(eat_cake: 'yes!', have_cake: 'yes!').messages).to eql(
        be_reasonable: ['you cannot eat cake and have cake!']
      )
    end
  end
end
