# frozen_string_literal: true

require "dry/validation/contract"

RSpec.describe Dry::Validation::Contract, "Rule#each" do
  subject(:contract) { contract_class.new }

  context "using a block" do
    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        def self.name
          "TestContract"
        end

        params do
          required(:nums).array(:integer)
          optional(:small_integers).array(:integer)
          optional(:hash).hash do
            optional(:another_nums).array(:integer)
          end
        end

        rule(:nums).each do
          key.failure("invalid") if value < 3
        end

        rule(:small_integers).each do
          key.failure(:too_big) if value > 9
        end

        rule(hash: :another_nums).each do
          key.failure("invalid") if value < 3
        end

        rule(:nums).each do |context:|
          context[:sum] ||= 0
          context[:sum] += value
        end
      end
    end

    it "applies rule only when the value is an array" do
      expect(contract.(nums: "oops").errors.to_h).to eql(nums: ["must be an array"])
    end

    it "applies rule when an item passed schema checks" do
      expect(contract.(nums: ["oops", 1, 4, 0]).errors.to_h)
        .to eql(nums: {0 => ["must be an integer"], 1 => ["invalid"], 3 => ["invalid"]})
    end

    it "applies rule to nested values when an item passed schema checks" do
      expect(contract.(nums: [4], hash: {another_nums: ["oops", 1, 4]}).errors.to_h)
        .to eql(hash: {another_nums: {0 => ["must be an integer"], 1 => ["invalid"]}})
    end

    it "passes block options" do
      expect(contract.(nums: [10, 20]).context[:sum]).to eql(30)
    end

    it "returns error from the rule namespace without an index" do
      contract_class.config.messages.load_paths << SPEC_ROOT.join("fixtures/messages/errors.en.yml").realpath
      expect(contract.(small_integers: [11, 12], nums: [1]).errors.to_h)
          .to eql(small_integers: { 0 => ["is too big!"],
                                    1 => ["is too big!"]},
                  nums: { 0 => ["invalid"] })
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
          required(:nums).filled(:array)
          optional(:hash).hash do
            optional(:another_nums).filled(:array)
          end
        end

        rule(:nums).each(:even?)
        rule("hash.another_nums").each(:even?)
      end
    end

    it "applies rule when an item passed schema checks" do
      expect(contract.(nums: [2, 3]).errors.to_h)
        .to eql(nums: {1 => ["invalid"]})
    end

    it "applies rule to nested values when an item passed schema checks" do
      expect(contract.(nums: [4], hash: {another_nums: [2, 3]}).errors.to_h)
        .to eql(hash: {another_nums: {1 => ["invalid"]}})
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
          required(:nums).filled(:array)
          optional(:hash).hash do
            required(:another_nums).filled(:array)
          end
        end

        rule(:nums).each(:even?, :below_ten?)
        rule(%i[hash another_nums]).each(:even?, :below_ten?)
      end
    end

    it "applies rules when an item passed schema checks" do
      expect(contract.(nums: [2, 15]).errors.to_h)
        .to eql(nums: {1 => ["invalid", "too big"]})
    end

    it "applies rules for nested values when an item passed schema checks" do
      expect(contract.(nums: [2], hash: {another_nums: [2, 15]}).errors.to_h)
        .to eql(hash: {another_nums: {1 => ["invalid", "too big"]}})
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
          required(:nums).array(:integer)
          optional(:hash).hash do
            optional(:another_nums).array(:integer)
          end
        end

        rule(:nums).each(min: 3)
        rule(hash: :another_nums).each(min: 3)
      end
    end

    it "applies rule when an item passed schema checks" do
      expect(contract.(nums: ["oops", 1, 4, 0]).errors.to_h)
        .to eql(nums: {0 => ["must be an integer"], 1 => ["invalid"], 3 => ["invalid"]})
    end

    it "applies rule to nested values when an item passed schema checks" do
      expect(contract.(nums: [4], hash: {another_nums: ["oops", 1, 4]}).errors.to_h)
        .to eql(hash: {another_nums: {0 => ["must be an integer"], 1 => ["invalid"]}})
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
          required(:nums).array(:integer)
          optional(:hash).hash do
            optional(:another_nums).array(:integer)
          end
        end

        rule(:nums).each(between: [3, 5])
        rule(hash: :another_nums).each(between: [3, 5])
      end
    end

    it "applies rule when an item passed schema checks" do
      expect(contract.(nums: ["oops", 4, 0, 6]).errors.to_h)
        .to eql(nums: {0 => ["must be an integer"], 2 => ["invalid"], 3 => ["invalid"]})
    end

    it "applies rule with nested values when an item passed schema checks" do
      expect(contract.(nums: [4], hash: {another_nums: ["oops", 4, 0]}).errors.to_h)
        .to eql(hash: {another_nums: {0 => ["must be an integer"], 2 => ["invalid"]}})
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
          key.failure("invalid") if value < min
        end

        register_macro(:max) do |macro:|
          max = macro.args[0]
          key.failure("invalid") if value > max
        end

        params do
          required(:nums).array(:integer)
          optional(:hash).hash do
            optional(:another_nums).array(:integer)
          end
        end

        rule(:nums).each(min: 3, max: 5)
        rule(hash: :another_nums).each(min: 3, max: 5)
      end
    end

    it "applies rules when an item passed schema checks" do
      expect(contract.(nums: ["oops", 4, 0, 6]).errors.to_h)
        .to eql(nums: {0 => ["must be an integer"], 2 => ["invalid"], 3 => ["invalid"]})
    end

    it "applies rules for nested values when an item passed schema checks" do
      expect(contract.(nums: [4], hash: {another_nums: ["oops", 4, 0]}).errors.to_h)
        .to eql(hash: {another_nums: {0 => ["must be an integer"], 2 => ["invalid"]}})
    end
  end
end
