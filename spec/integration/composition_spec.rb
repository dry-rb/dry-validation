# frozen_string_literal: true

require 'dry/validation/composition'

RSpec.describe Dry::Validation::Composition do
  let(:step) { Dry::Validation::Composition::Step }
  let(:path) { Dry::Schema::Path }

  subject(:composition) { Dry::Validation::Composition.new(steps) }

  before do
    class Test::Contract < Dry::Validation::Contract
      schema { required(:email).filled(:string) }
    end
  end

  describe 'with no steps' do
    let(:steps) { [] }

    it '#call returns a succesful Composition::Result' do
      expect(subject.call({})).to be_success
    end
  end

  describe 'with steps' do
    let(:steps) { [step.new(Test::Contract, nil)] }

    it 'has a nice string representation' do
      expect(composition.inspect)
        .to eq '#<Dry::Validation::Composition steps=[Test::Contract]>'
    end

    describe '#add_step(contract, Schema::Path["foo"])' do
      before { composition.add_step(Test::Contract, path['foo']) }

      it 'adds to the composition steps' do
        expect(composition.steps).to eq([
          step.new(Test::Contract, nil),
          step.new(Test::Contract, path['foo'])
        ])
      end

      it 'does not mutate the original steps' do
        expect(steps).to eq [step.new(Test::Contract, nil)]
      end

      it 'has a nice string representation' do
        expect(composition.inspect).to include(
          'steps=[Test::Contract, foo => Test::Contract]>'
        )
      end
    end
  end
end
