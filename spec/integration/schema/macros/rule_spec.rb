RSpec.describe 'Macros / rule' do
  shared_context 'password confirmation high-level rule' do
    subject(:schema) { schema_class.new }

    let(:schema_class) do
      Dry::Validation.Schema(build: false) do
        required(:user).schema do
          required(:password).filled
          required(:password_confirmation).filled

          rule(password_confirmation: %i[password_confirmation password]) do |pc, p|
            pc.eql?(p)
          end
        end
      end
    end

    it 'passes when input is valid' do
      expect(schema.(user: { password: 'foo', password_confirmation: 'foo' })).to be_successful
    end

    it 'fails when the rule failed' do
      expect(schema.(user: { password: 'foo', password_confirmation: 'bar' }).messages).to eql(
        user: { password_confirmation: [error_message] }
      )
    end
  end

  context 'with the default message' do
    let(:error_message) { 'must be equal to foo' }

    include_context 'password confirmation high-level rule'
  end

  context 'with a custom message' do
    let(:error_message) { 'does not match' }

    before do
      schema_class.class_eval do
        def self.messages
          default_messages.merge(en: { errors: { password_confirmation: 'does not match' } })
        end
      end
    end

    include_context 'password confirmation high-level rule'
  end
end
