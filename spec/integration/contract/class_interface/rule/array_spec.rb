# frozen_string_literal: true

require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, 'Rule#each' do
  subject(:contract) { contract_class.new }

  let(:contract_class) do
    Class.new(Dry::Validation::Contract) do
      def self.name
        'TestContract'
      end

      params do
        required(:nums).array(:integer)
      end

      rule(:nums).each do
        key.failure('invalid') if value < 3
      end
    end
  end

  context 'when the value is an array' do
    it 'applies rule when an item passed schema checks' do
      expect(contract.(nums: ['oops', 1, 4, 0]).errors.to_h)
        .to eql(nums: { 0 => ['must be an integer'], 1 => ['invalid'], 3 => ['invalid']})
    end
  end
end
