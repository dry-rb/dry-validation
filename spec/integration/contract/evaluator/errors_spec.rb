# frozen_string_literal: true

RSpec.describe Dry::Validation::Evaluator do
  describe "#schema_error?" do
    let(:contract) do
      Class.new(Dry::Validation::Contract) do
        schema do
          required(:email).filled(:string)
          required(:name).filled(:string)
        end

        rule(:name) do
          key.failure("first introduce a valid email") if schema_error?(:email)
        end
      end
    end

    it "checks for errors in given key" do
      expect(contract.new.(email: nil, name: "foo").errors.to_h).to eql(
        email: ["must be a string"],
        name: ["first introduce a valid email"]
      )
    end
  end

  describe "#rule_error?" do
    let(:contract) do
      Class.new(Dry::Validation::Contract) do
        schema do
          required(:foo).filled(:string)
        end

        rule(:foo) do
          key.failure("failure added")
          key.failure("failure added after checking") if rule_error?
        end
      end
    end

    it "checks for errors in current rule" do
      expect(contract.new.(foo: "some@email.com").errors.to_h).to eql(
        foo: ["failure added", "failure added after checking"]
      )
    end
  end
end
