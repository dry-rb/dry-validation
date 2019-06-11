# frozen_string_literal: true

require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, 'Rule#each' do
  subject(:contract) { contract_class.new }

  context 'using a block' do
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

    it 'applies rule when an item passed schema checks' do
      expect(contract.(nums: ['oops', 1, 4, 0]).errors.to_h)
        .to eql(nums: { 0 => ['must be an integer'], 1 => ['invalid'], 3 => ['invalid'] })
    end
  end

  context 'using a macro with args' do
    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        def self.name
          'TestContract'
        end

        register_macro(:min) do |macro:|
          min = macro.args[0]
          key.failure('invalid') if value < min
        end

        register_macro(:max) do |macro:|
          max = macro.args[0]
          key.failure('invalid') if value > max
        end

        params do
          required(:nums).array(:integer)
        end

        rule(:nums).each(min: 3, max: 5)
      end
    end

    it 'applies rule when an item passed schema checks' do
      expect(contract.(nums: ['oops', 4, 0, 6]).errors.to_h)
        .to eql(nums: { 0 => ['must be an integer'], 2 => ['invalid'], 3 => ['invalid'] })
    end
  end

  context 'using a simple macro' do
    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        def self.name
          'TestContract'
        end

        register_macro(:even?) do
          key.failure('invalid') unless value.even?
        end

        params do
          required(:nums).filled(:array)
        end

        rule(:nums).each(:even?)
      end
    end

    it 'applies rule when an item passed schema checks' do
      expect(contract.(nums: [2, 3]).errors.to_h)
        .to eql(nums: { 1 => ['invalid'] })
    end
  end
end
