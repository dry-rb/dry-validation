RSpec.describe Schema, 'using high-level grouped rules' do
  subject(:validate) { schema.new }

  let(:schema) do
    Class.new(Schema) do
      def self.messages
        Messages.default.merge(
          en: {
            errors: {
              email: {
                absence: 'email must not be selected',
                presence: 'email must be selected',
                format: 'this is not an email lol',
                inclusion: 'sorry, did not expect this lol'
              }
            }
          }
        )
      end

      key(:email) { |email| email.none? | email.filled? }
      key(:login) { |login| login.bool? }

      rule(email: :absence) do
        value(:login).false? > value(:email).none?
      end

      rule(email: :presence) do
        value(:login).true? > value(:email).filled?
      end

      rule(email: :format) do
        value(:email).filled? > value(:email).format?(/[a-z]@[a-z]/)
      end

      rule(email: :inclusion) do
        value(:email).filled? > value(:email).inclusion?(%w[jane@doe])
      end
    end
  end

  it 'passes when login is true and email is present' do
    expect(validate.(login: true, email: 'jane@doe').messages).to be_empty
  end

  it 'fails when login is false and email is not present' do
    expect(validate.(login: true, email: nil).messages).to_not be_empty
  end

  it 'provides merged error messages' do
    expect(validate.(login: true, email: 'not-an-email-lol').messages).to eql(
      email: [
        ["sorry, did not expect this lol", "this is not an email lol"], nil
      ]
    )
  end
end
