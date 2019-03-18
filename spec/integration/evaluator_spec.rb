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

  describe 'delegation' do
    let(:block) do
      proc {
        key.failure('it works') if works?
      }
    end

    it 'delegates to the context' do
      expect(context).to receive(:works?).and_return(true)
      expect(evaluator.failures[0][:path].to_a).to eql([:email])
      expect(evaluator.failures[0][:message]).to eql('it works')
    end

    describe 'with custom methods defined on the context' do
      let(:context) do
        double(context: :my_context)
      end

      let(:block) do
        proc { key.failure("message with #{context}") }
      end

      it 'forwards to the context' do
        expect(evaluator.failures[0][:message]).to eql('message with my_context')
      end
    end
  end
end
