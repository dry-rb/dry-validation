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
    context "without argument" do
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

    context "with argument" do
      let(:contract) do
        Class.new(Dry::Validation::Contract) do
          schema do
            required(:name).filled(:string)
            required(:email).filled(:string)
          end

          rule(:name) do
            key.failure("expected")
          end

          rule(:email) do
            key.failure("also expected") if rule_error?(:name)
          end
        end
      end

      it "checks for error in rule with name provided in argument" do
        expect(contract.new.(name: "John", email: "some@email.com").errors.to_h).to eql(
          {name: ["expected"], email: ["also expected"]}
        )
      end

      it "does not evaluate if schema with provided key is falling down" do
        expect(contract.new.(name: nil, email: "some@email.com").errors.to_h).to eql(
          {name: ["must be a string"]}
        )
      end
    end
  end

  describe "#base_error?" do
    let(:contract) do
      Class.new(Dry::Validation::Contract) do
        schema do
          required(:foo).filled(:string)
        end

        rule do
          base.failure("first base failure")
          base.failure("base failure added after checking") if base_error?
        end

        rule do
          unless base_error?
            base.failure("rule should be checked only if the first base_rule was kept")
          end
        end
      end
    end

    it "checks for base errors" do
      expect(contract.new.(foo: "some@email.com").errors.to_h).to eql(
        nil => ["first base failure", "base failure added after checking"]
      )
    end
  end
end
