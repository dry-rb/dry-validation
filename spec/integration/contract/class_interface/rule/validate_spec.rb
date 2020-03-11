# frozen_string_literal: true

require "dry/validation/contract"

RSpec.describe Dry::Validation::Contract, "Rule#validate" do
  subject(:contract) { contract_class.new }

  context "using a block" do
    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        def self.name
          "TestContract"
        end

        params do
          required(:num).filled(:integer)
        end

        rule(:num).validate do
          key.failure("invalid") if value < 3
        end
      end
    end

    it "applies rule when an item passed schema checks" do
      expect(contract.(num: 2).errors.to_h)
        .to eql(num: ["invalid"])
    end
  end

  context "using a simple macro" do
    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        def self.name
          "TestContract"
        end

        register_macro(:even?) do
          key.failure("invalid") unless value.even?
        end

        params do
          required(:num).filled(:integer)
        end

        rule(:num).validate(:even?)
      end
    end

    it "applies first rule when an item passed schema checks" do
      expect(contract.(num: 3).errors.to_h)
        .to eql(num: ["invalid"])
    end
  end

  context "using multiple macros" do
    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        def self.name
          "TestContract"
        end

        register_macro(:even?) do
          key.failure("invalid") unless value.even?
        end

        register_macro(:below_ten?) do
          key.failure("too big") unless value < 10
        end

        params do
          required(:num).filled(:integer)
        end

        rule(:num).validate(:even?, :below_ten?)
      end
    end

    it "applies rules when an item passed schema checks" do
      expect(contract.(num: 15).errors.to_h)
        .to eql(num: ["invalid", "too big"])
    end
  end

  context "using a macro with args" do
    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        def self.name
          "TestContract"
        end

        register_macro(:min) do |macro:|
          min = macro.args[0]
          key.failure("invalid") if value < min
        end

        params do
          required(:num).filled(:integer)
        end

        rule(:num).validate(min: 3)
      end
    end

    it "applies rule when an item passed schema checks" do
      expect(contract.(num: 2).errors.to_h)
        .to eql(num: ["invalid"])
    end
  end

  context "using a macro with multiple args" do
    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        def self.name
          "TestContract"
        end

        register_macro(:between) do |macro:|
          min, max = macro.args[0..1]
          key.failure("invalid") unless (min..max).cover?(value)
        end

        params do
          required(:num).filled(:integer)
        end

        rule(:num).validate(between: [3, 5])
      end
    end

    it "applies rule when an item passed schema checks" do
      expect(contract.(num: 2).errors.to_h)
        .to eql(num: ["invalid"])
    end
  end

  context "using multiple macros with args" do
    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        def self.name
          "TestContract"
        end

        register_macro(:min) do |macro:|
          min = macro.args[0]
          key.failure("too small") if value < min
        end

        register_macro(:max) do |macro:|
          max = macro.args[0]
          key.failure("too big") if value > max
        end

        params do
          required(:num).filled(:integer)
        end

        rule(:num).validate(min: 3, max: 5)
      end
    end

    it "applies first rule when an item passed schema checks" do
      expect(contract.(num: 2).errors.to_h)
        .to eql(num: ["too small"])
    end

    it "applies second rule when an item passed schema checks" do
      expect(contract.(num: 6).errors.to_h)
        .to eql(num: ["too big"])
    end
  end
end
