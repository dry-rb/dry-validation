# frozen_string_literal: true

require "dry/validation/evaluator"

RSpec.describe Dry::Validation::Evaluator do
  subject(:evaluator) do
    Dry::Validation::Evaluator.new(contract, **options, &block)
  end

  let(:contract) do
    double(:contract)
  end

  let(:options) do
    {keys: [:email], result: {}, values: values, _context: {}}
  end

  let(:values) do
    {}
  end

  describe "delegation" do
    let(:block) do
      proc {
        key.failure("it works") if works?
      }
    end

    it "delegates to the contract" do
      expect(contract).to receive(:works?).and_return(true)
      expect(evaluator.failures[0][:path].to_a).to eql([:email])
      expect(evaluator.failures[0][:message]).to eql("it works")
    end

    describe "with custom methods defined on the contract" do
      let(:contract) do
        double(contract: :my_contract)
      end

      let(:block) do
        proc { key.failure("message with #{contract}") }
      end

      it "forwards to the contract" do
        expect(evaluator.failures[0][:message]).to eql("message with my_contract")
      end
    end
  end
end
