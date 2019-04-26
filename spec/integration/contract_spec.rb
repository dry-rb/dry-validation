require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract do
  subject(:contract) do
    Test::NewUserContract.new
  end

  before do
    class Test::NewUserContract < Dry::Validation::Contract
      params do
        required(:email).filled(:string)
      end

      rule(:email) do
        key.failure('must be unique')
      end
    end
  end

  describe '#inspect' do
    it 'returns a string representation' do
      expect(contract.inspect).to eql(
        %(#<Test::NewUserContract schema=#<Dry::Schema::Params keys=["email"] rules={:email=>"key?(:email) AND key[email](str? AND filled?)"}> rules=[#<Dry::Validation::Rule keys=[:email]>]>)
      )
    end
  end
end
