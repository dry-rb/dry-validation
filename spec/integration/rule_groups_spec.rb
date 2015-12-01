RSpec.describe Dry::Validation::Schema do
  subject(:validation) { schema.new }

  describe 'defining schema with rule groups' do
    let(:schema) do
      Class.new(Dry::Validation::Schema) do
        key(:password, &:filled?)
        key(:password_confirmation, &:filled?)

        group(eql?: [:password, :password_confirmation])
      end
    end

    describe '#call' do
      it 'checks confirmation of password' do
        expect(validation.(password: 'foo', password_confirmation: 'foo')).to be_empty
      end
    end
  end
end
