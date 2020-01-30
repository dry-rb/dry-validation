# frozen_string_literal: true

RSpec.describe Dry::Validation::Evaluator do
  describe '#schema_error?' do
    let(:contract) do
      Class.new(Dry::Validation::Contract) do
        schema do
          required(:email).filled(:string)
          required(:name).filled(:string)
        end

        rule(:name) do
          key.failure('first introduce a valid email') if schema_error?(:email)
        end
      end
    end

    it 'checks for errors in given key' do
      expect(contract.new.(email: nil, name: 'foo').errors.to_h).to eql({
        email: ['must be a string'],
        name: ['first introduce a valid email']
      })
    end
  end
end
