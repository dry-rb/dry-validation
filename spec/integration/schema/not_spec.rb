RSpec.describe 'Schema with negated rules' do
  subject(:validate) { schema.new }

  let(:schema) do
    Class.new(Dry::Validation::Schema) do
      def self.messages
        Messages.default.merge(
          en: { errors: { be_reasonable: 'you cannot eat cake and have cake!' } }
        )
      end

      optional(:eat_cake) { |v| v.eql?('yes!') }
      optional(:have_cake) { |v| v.eql?('yes!') }

      rule(:be_reasonable) do
        rule(:eat_cake) & rule(:have_cake).not
      end
    end
  end

  describe '#messages' do
    it 'passes when only one option is selected' do
      messages = validate.(eat_cake: 'yes!', have_cake: 'no!').messages[:be_reasonable]

      expect(messages).to be(nil)
    end

    it 'fails when both options are selected' do
      messages = validate.(eat_cake: 'yes!', have_cake: 'yes!').messages[:be_reasonable]

      expect(messages).to eql([['you cannot eat cake and have cake!'], 'yes!'])
    end
  end
end
