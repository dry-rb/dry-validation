# frozen_string_literal: true

require 'dry/validation/evaluator'

RSpec.describe Dry::Validation::Evaluator do
  subject(:evaluator) do
    Dry::Validation::Evaluator.new(context, options, &block)
  end

  let(:context) do
    double(:context)
  end

  let(:options) do
    { keys: [:email], values: values }
  end

  let(:values) do
    {}
  end

  describe '#failure' do
    let(:block) do
      proc { failure('oops') }
    end

    it 'sets a failure message' do
      expect(evaluator.message).to eql([:email, 'oops'])
    end
  end

  describe '#failure?' do
    context 'when failure message was set' do
      let(:block) do
        proc { failure('oops') }
      end

      it 'returns true' do
        expect(evaluator).to be_failure
      end
    end

    context 'when failure message was not set' do
      let(:block) do
        proc {}
      end

      it 'returns false' do
        expect(evaluator).to_not be_failure
      end
    end
  end

  describe 'delegation' do
    let(:block) do
      proc {
        failure('it works') if works?
      }
    end

    it 'delegates to the context' do
      expect(context).to receive(:works?).and_return(true)
      expect(evaluator.message).to eql([:email, 'it works'])
    end
  end
end
