# frozen_string_literal: true

require "dry/validation/contract"

RSpec.describe Dry::Validation::Contract do
  subject(:contract) do
    Test::NewUserContract.new
  end

  before do
    class Test::NewUserContract < Dry::Validation::Contract
      params do
        required(:email).filled(:string)
      end

      rule(:email) do
        key.failure("must be unique")
      end
    end
  end

  describe "#inspect" do
    it "returns a string representation" do
      if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4.0")
        expect(contract.inspect).to eql(
          %(#<Test::NewUserContract schema=#<Dry::Schema::Params keys=["email"] rules={email: "key?(:email) AND key[email](filled? AND str?)"}> rules=[#<Dry::Validation::Rule keys=[:email]>]>)
        )
      else
        expect(contract.inspect).to eql(
          %(#<Test::NewUserContract schema=#<Dry::Schema::Params keys=["email"] rules={:email=>"key?(:email) AND key[email](filled? AND str?)"}> rules=[#<Dry::Validation::Rule keys=[:email]>]>)
        )
      end
    end
  end

  describe ".new" do
    it "raises error when schema is not defined" do
      Test::NewUserContract.instance_variable_set("@__schema__", nil)

      expect { Test::NewUserContract.new }.to raise_error(
        Dry::Validation::SchemaMissingError,
        "Test::NewUserContract cannot be instantiated without a schema defined"
      )
    end
  end
end
