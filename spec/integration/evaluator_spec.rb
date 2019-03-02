require 'dry/validation/evaluator'

RSpec.describe Dry::Validation::Evaluator do
  subject(:evaluator) do
    Dry::Validation::Evaluator.new(context, options, &block)
  end

  let(:context) do
    double(:context)
  end

  let(:options) do
    { name: :email, values: values }
  end

  let(:values) do
    {}
  end

  describe '#failure' do
    let(:block) do
      Proc.new { failure('oops') }
    end

    it 'sets a failure message' do
      expect(evaluator.message).to eql('oops')
    end
  end

  describe '#failure?' do
    context 'when failure message was set' do
      let(:block) do
        Proc.new { failure("oops") }
      end

      it 'returns true' do
        expect(evaluator).to be_failure
      end
    end

    context 'when failure message was not set' do
      let(:block) do
        Proc.new {}
      end

      it 'returns false' do
        expect(evaluator).to_not be_failure
      end
    end
  end

  describe 'delegation' do
    let(:block) do
      Proc.new {
        failure('it works') if works?
      }
    end

    it 'delegates to the context' do
      expect(context).to receive(:works?).and_return(true)
      expect(evaluator.message).to eql('it works')
    end
  end
end