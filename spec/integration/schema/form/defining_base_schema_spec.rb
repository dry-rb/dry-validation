require 'dry/validation/messages/i18n'
require 'i18n'

RSpec.describe 'Defining base schema class' do
  subject(:schema) do
    Dry::Validation.Form(BaseSchema) do
      required(:email).filled(:email?)
    end
  end

  before do
    class BaseSchema < Dry::Validation::Schema
      configure do |config|
        config.messages_file = SPEC_ROOT.join('fixtures/locales/en.yml')
        config.messages = :i18n
      end

      def email?(value)
        true
      end

      define! do
        required(:name).filled
      end
    end
  end

  after do
    Object.send(:remove_const, :BaseSchema)
  end

  it 'inherits predicates' do
    expect(schema).to respond_to(:email?)
  end

  it 'inherits rules' do
    expect(schema.('name' => '').messages).to eql(
      name: ['must be filled'], email: ['is missing', 'must be an email']
    )
  end
end
