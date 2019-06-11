# frozen_string_literal: true

require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, 'Rule#validate' do
  subject(:contract) { contract_class.new }

  context 'using a block' do
    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        def self.name
          'TestContract'
        end

        params do
          required(:num).filled(:integer)
        end

        rule(:num).validate do
          key.failure('invalid') if value < 3
        end
      end
    end

    it 'applies rule when an item passed schema checks' do
      expect(contract.(num: 2).errors.to_h)
        .to eql(num: ['invalid'])
    end
  end

  context 'using a simple macro' do
    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        def self.name
          'TestContract'
        end

        register_macro(:min) do
          key.failure('too small') if value < 3
        end

        register_macro(:max) do
          key.failure('too big') if value > 5
        end

        params do
          required(:num).filled(:integer)
        end

        rule(:num).validate(:min, :max)
      end
    end

    it 'applies first rule when an item passed schema checks' do
      expect(contract.(num: 2).errors.to_h)
        .to eql(num: ['too small'])
    end

    it 'applies second rule when an item passed schema checks' do
      expect(contract.(num: 6).errors.to_h)
        .to eql(num: ['too big'])
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
          key.failure('too small') if value < min
        end

        register_macro(:max) do |macro:|
          max = macro.args[0]
          key.failure('too big') if value > max
        end

        params do
          required(:num).filled(:integer)
        end

        rule(:num).validate(min: 3, max: 5)
      end
    end

    it 'applies first rule when an item passed schema checks' do
      expect(contract.(num: 2).errors.to_h)
        .to eql(num: ['too small'])
    end

    it 'applies second rule when an item passed schema checks' do
      expect(contract.(num: 6).errors.to_h)
        .to eql(num: ['too big'])
    end
  end
end
