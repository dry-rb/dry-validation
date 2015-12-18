RSpec.describe Schema, 'using generic rules' do
  subject(:validate) { schema.new }

  let(:schema) do
    Class.new(Schema) do
      def self.messages
        Messages.default.merge(
          en: { errors: { destiny: 'you must select either red or blue' } }
        )
      end

      optional(:red, &:filled?)
      optional(:blue, &:filled?)

      rule(destiny: [:red, :blue]) { |red, blue| red | blue }
    end
  end

  it 'passes when only red is filled' do
    expect(validate.(red: '1')).to be_empty
  end

  it 'fails when red and blue are not filled ' do
    expect(validate.(red: '', blue: '').messages[:destiny]).to eql(
      [['you must select either red or blue'], '']
    )
  end
end
