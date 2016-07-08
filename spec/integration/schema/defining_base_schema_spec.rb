RSpec.describe 'Defining base schema class' do
  subject(:schema) do
    Dry::Validation.Schema(BaseSchema) do
      required(:email).filled(:email?)
    end
  end

  before do
    class BaseSchema < Dry::Validation::Schema
      configure do |config|
        config.messages_file = SPEC_ROOT.join('fixtures/locales/en.yml')
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
    expect(schema.(name: nil).messages).to eql(
      name: ['must be filled'], email: ['is missing', 'must be an email']
    )
  end

  it 'inherits messages' do
    expect(schema.class.messages).to be(BaseSchema.messages)
  end

  it 'inherits error compiler' do
    expect(schema.class.error_compiler).to be(BaseSchema.error_compiler)
  end
end
