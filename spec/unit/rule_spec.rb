# frozen_string_literal: true

RSpec.describe Dry::Validation::Contract, '.rule' do
  subject(:contract) { contract_class.new }

  context 'with an array key' do
    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        schema do
          required(:tags).array(:hash) do
            required(:name).filled(:string)
          end
        end
      end
    end

    it 'allows specifying a rule for array elements' do
      contract_class.rule(:tags) do
        key.failure('must have at least 1 element') unless value.size > 0
      end

      expect(contract.(tags: []).errors.to_h).to eql(
        tags: ['must have at least 1 element']
      )
    end

    it 'shows the correct error message' do
      contract_class.rule(:tags) do
        key.failure('must have at least 1 element') unless value.size > 0
      end

      expect(contract.(tags: [], name: '').errors.to_h).to eql(
        tags: ['must have at least 1 element']
      )

      expect(contract.(tags: [], name: '').errors(full: true).to_h).to eql(
        tags: ['tags must have at least 1 element']
      )
    end
  end
end
