# frozen_string_literal: true

require "dry/validation/extensions/predicates_as_macros"

RSpec.describe Dry::Validation::Contract do
  context "with predicates_as_macros extension" do
    before { Dry::Validation.load_extensions(:predicates_as_macros) }

    subject(:contract) do
      Class.new(Dry::Validation::Contract) do
        import_predicates_as_macros
      end
    end

    let(:registry) { Dry::Validation::PredicateRegistry.new }

    %i[
      filled? format? gt? gteq? included_in? includes? inclusion? is? lt?
      lteq? max_size? min_size? not_eql? odd? respond_to? size? true?
      uuid_v4?
    ].each do |predicate|
      it "imports #{predicate}" do
        expect(
          registry.key?(predicate) && contract.macros.key?(predicate)
        ).to be(true)
      end
    end

    it "macros succeed on predicate success" do
      age_contract = Class.new(contract) do
        schema do
          required(:age).filled(:integer)
        end

        rule(:age).validate(gteq?: 18)
      end.new

      expect(age_contract.(age: 19)).to be_success
    end

    it "macros fail on predicate failure" do
      age_contract = Class.new(contract) do
        schema do
          required(:age).filled(:integer)
        end

        rule(:age).validate(gteq?: 18)
      end.new

      expect(age_contract.(age: 17)).to be_failure
    end

    it "failure message is built from predicate name and arguments" do
      age_contract = Class.new(contract) do
        schema do
          required(:age).filled(:integer)
        end

        rule(:age).validate(gteq?: 18)
      end.new

      result = age_contract.(age: 17)

      expect(
        result.errors.first.text
      ).to eq("must be greater than or equal to 18")
    end
  end
end
