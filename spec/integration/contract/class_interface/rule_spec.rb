# frozen_string_literal: true

require "dry/validation/contract"

RSpec.describe Dry::Validation::Contract, ".rule" do
  subject(:contract) { contract_class.new }

  let(:contract_class) do
    Class.new(Dry::Validation::Contract) do
      def self.name
        "TestContract"
      end

      params do
        required(:email).filled(:string)
        optional(:login).filled(:string)

        optional(:details).hash do
          optional(:address).hash do
            required(:street).value(:string)
          end
        end
      end
    end
  end

  context "when the name matches one of the keys" do
    before do
      contract_class.rule(:login) do
        key.failure("is too short") if values[:login].size < 3
      end
    end

    it "applies rule when value passed schema checks" do
      expect(contract.(email: "jane@doe.org", login: "ab").errors.to_h).to eql(
        login: ["is too short"]
      )
    end
  end

  context "when the name does not match one of the keys" do
    before do
      contract_class.rule do
        key(:custom).failure("this works")
      end
    end

    it "applies the rule regardless of the schema result" do
      expect(contract.(email: "jane@doe.org", login: "jane").errors.to_h).to eql(
        custom: ["this works"]
      )
    end
  end

  context "with a hash as the key identifier" do
    before do
      contract_class.rule(details: {address: :street}) do
        key.failure("cannot be empty") if values[:details][:address][:street].strip.empty?
      end
    end

    it "applies the rule when nested value passed schema checks" do
      expect(contract.(email: "jane@doe.org", login: "jane", details: nil).errors.to_h).to eql(
        details: ["must be a hash"]
      )

      expect(contract.(email: "jane@doe.org", login: "jane", details: {address: nil}).errors.to_h).to eql(
        details: {address: ["must be a hash"]}
      )

      expect(
        contract.(email: "jane@doe.org", login: "jane", details: {address: {street: " "}}).errors.to_h
      ).to eql(details: {address: {street: ["cannot be empty"]}})
    end
  end

  context "with a rule for nested hash and another rule for its member" do
    before do
      contract_class.rule(details: :address) do
        key.failure("invalid no matter what")
      end

      contract_class.rule(details: :address) do
        key.failure("seriously invalid")
      end

      contract_class.rule(details: {address: :street}) do
        key.failure("cannot be empty") if values[:details][:address][:street].strip.empty?
      end

      contract_class.rule(details: {address: :street}) do
        key.failure("must include a number") unless values[:details][:address][:street].match?(/\d+/)
      end
    end

    it "applies the rule when nested value passed schema checks" do
      expect(
        contract.(email: "jane@doe.org", login: "jane", details: {address: {street: " "}}).errors.to_h
      ).to eql(
        details: {address: [
          ["invalid no matter what", "seriously invalid"],
          {street: ["cannot be empty", "must include a number"]}
        ]}
      )
    end
  end

  context "with a rule that sets a general base error for the whole input" do
    before do
      contract_class.rule do
        key.failure("this whole thing is invalid")
      end
    end

    it "sets a base error not attached to any key" do
      expect(contract.(email: "jane@doe.org", login: "").errors.to_h).to eql(
        login: ["must be filled"], nil => ["this whole thing is invalid"]
      )

      expect(contract.(email: "jane@doe.org", login: "").errors.filter(:base?).map(&:to_s)).to eql(
        ["this whole thing is invalid"]
      )
    end
  end

  context "with a list of keys" do
    before do
      contract_class.rule(:email, :login) do
        if !values[:email].empty? && !values[:login].empty?
          key(:login).failure("is not needed when email is provided")
        end
      end
    end

    it "applies the rule when all values passed schema checks" do
      expect(contract.(email: nil, login: nil).errors.to_h).to eql(
        email: ["must be filled"], login: ["must be filled"]
      )

      expect(contract.(email: "jane@doe.org", login: "jane").errors.to_h).to eql(
        login: ["is not needed when email is provided"]
      )
    end
  end

  context "when keys are missing in the schema" do
    it "raises error with a list of symbol keys" do
      expect { contract_class.rule(:invalid, :wrong) }.to raise_error(
        Dry::Validation::InvalidKeysError,
        "TestContract.rule specifies keys that are not defined by the schema: [:invalid, :wrong]"
      )
    end

    it "raises error with a hash path" do
      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4.0")
        expect { contract_class.rule(invalid: :wrong) }.to raise_error(
          Dry::Validation::InvalidKeysError,
          "TestContract.rule specifies keys that are not defined by the schema: [{invalid: :wrong}]"
        )
      else
        expect { contract_class.rule(invalid: :wrong) }.to raise_error(
          Dry::Validation::InvalidKeysError,
          "TestContract.rule specifies keys that are not defined by the schema: [{:invalid=>:wrong}]"
        )
      end
    end

    it "raises error with a dot notation" do
      expect { contract_class.rule("invalid.wrong") }.to raise_error(
        Dry::Validation::InvalidKeysError,
        'TestContract.rule specifies keys that are not defined by the schema: ["invalid.wrong"]'
      )
    end

    it "raises error with a hash path with multiple nested keys" do
      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4.0")
        expect { contract_class.rule(invalid: %i[wrong not_here]) }.to raise_error(
          Dry::Validation::InvalidKeysError,
          "TestContract.rule specifies keys that are not defined by the schema: [{invalid: [:wrong, :not_here]}]"
        )
      else
        expect { contract_class.rule(invalid: %i[wrong not_here]) }.to raise_error(
          Dry::Validation::InvalidKeysError,
          "TestContract.rule specifies keys that are not defined by the schema: [{:invalid=>[:wrong, :not_here]}]"
        )
      end
    end
  end

  context "when keys are prefixes of valid keys" do
    it "raises error with a list of symbol keys" do
      expect { contract_class.rule(:details, :addres) }.to raise_error(
        Dry::Validation::InvalidKeysError,
        "TestContract.rule specifies keys that are not defined by the schema: [:addres]"
      )
    end

    it "raises error with a hash path" do
      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4.0")
        expect { contract_class.rule(details: :addres) }.to raise_error(
          Dry::Validation::InvalidKeysError,
          "TestContract.rule specifies keys that are not defined by the schema: [{details: :addres}]"
        )
      else
        expect { contract_class.rule(details: :addres) }.to raise_error(
          Dry::Validation::InvalidKeysError,
          "TestContract.rule specifies keys that are not defined by the schema: [{:details=>:addres}]"
        )
      end
    end

    it "raises error with a dot notation" do
      expect { contract_class.rule("details.addres") }.to raise_error(
        Dry::Validation::InvalidKeysError,
        'TestContract.rule specifies keys that are not defined by the schema: ["details.addres"]'
      )
    end

    it "raises error with a hash path with multiple nested keys" do
      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4.0")
        expect { contract_class.rule(details: %i[addres]) }.to raise_error(
          Dry::Validation::InvalidKeysError,
          "TestContract.rule specifies keys that are not defined by the schema: [{details: [:addres]}]"
        )
      else
        expect { contract_class.rule(details: %i[addres]) }.to raise_error(
          Dry::Validation::InvalidKeysError,
          "TestContract.rule specifies keys that are not defined by the schema: [{:details=>[:addres]}]"
        )
      end
    end
  end

  context "when keys are suffixes of valid keys" do
    it "raises error with a list of symbol keys" do
      expect { contract_class.rule(:etails, :address) }.to raise_error(
        Dry::Validation::InvalidKeysError,
        "TestContract.rule specifies keys that are not defined by the schema: [:etails, :address]"
      )
    end

    it "raises error with a hash path" do
      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4.0")
        expect { contract_class.rule(etails: :address) }.to raise_error(
          Dry::Validation::InvalidKeysError,
          "TestContract.rule specifies keys that are not defined by the schema: [{etails: :address}]"
        )
      else
        expect { contract_class.rule(etails: :address) }.to raise_error(
          Dry::Validation::InvalidKeysError,
          "TestContract.rule specifies keys that are not defined by the schema: [{:etails=>:address}]"
        )
      end
    end

    it "raises error with a dot notation" do
      expect { contract_class.rule("etails.address") }.to raise_error(
        Dry::Validation::InvalidKeysError,
        'TestContract.rule specifies keys that are not defined by the schema: ["etails.address"]'
      )
    end

    it "raises error with a hash path with multiple nested keys" do
      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4.0")
        expect { contract_class.rule(etails: %i[address]) }.to raise_error(
          Dry::Validation::InvalidKeysError,
          "TestContract.rule specifies keys that are not defined by the schema: [{etails: [:address]}]"
        )
      else
        expect { contract_class.rule(etails: %i[address]) }.to raise_error(
          Dry::Validation::InvalidKeysError,
          "TestContract.rule specifies keys that are not defined by the schema: [{:etails=>[:address]}]"
        )
      end
    end
  end

  describe "abstract contract" do
    let(:abstract_contract) do
      Class.new(Dry::Validation::Contract) do
        rule do
          base.failure("error from abstract contract")
        end
      end
    end

    let(:contract_class) do
      Class.new(abstract_contract) do
        params do
          required(:name).filled(:string)
        end
      end
    end

    it "applies rules from the parent abstract contract" do
      expect(contract.(name: "").errors.to_h).to eql(
        nil => ["error from abstract contract"], name: ["must be filled"]
      )
    end
  end
end
