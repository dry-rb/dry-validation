# frozen_string_literal: true

require 'dry/validation/composition'
require 'dry/validation/composition/builder'

RSpec.describe Dry::Validation::Composition::Builder do
  let(:step) { Dry::Validation::Composition::Step }
  let(:path) { Dry::Schema::Path }

  before do
    class Test::Contract < Dry::Validation::Contract
      schema { required(:email).filled(:string) }
    end
  end

  subject(:builder) { Dry::Validation::Composition::Builder.new(composition) }

  let(:composition) { Dry::Validation::Composition.new }

  describe '#contract' do
    it '(Contract) adds a step for the contract to the composition' do
      builder.contract Test::Contract
      expect(composition.steps[0]).to eq step.new(Test::Contract, nil)
    end

    it '(Contract, path:) adds a step for the contract at that path' do
      builder.contract Test::Contract, path: 'foo.bar'
      expect(composition.steps[0]).to eq step.new(Test::Contract, path.new([:foo, :bar]))
    end
  end

  describe '#path("foo.bar") { ... }' do
    before { builder.path('foo.bar', &block) }

    let(:block) { proc { contract Test::Contract } }

    it 'scopes the contracts in the block to that path' do
      expect(composition.steps[0]).to eq step.new(Test::Contract, path.new([:foo, :bar]))
    end

    describe 'with nested blocks and paths specified' do
      let(:block) do
        proc do
          contract Test::Contract
          path :baz do
            contract Test::Contract
            contract Test::Contract, path: 'bang'
          end
        end
      end

      it 'adds steps with the correct prefixes' do
        expect(composition.steps).to eq([
          step.new(Test::Contract, path['foo.bar']),
          step.new(Test::Contract, path['foo.bar.baz']),
          step.new(Test::Contract, path['foo.bar.baz.bang'])
        ])
      end
    end
  end
end
