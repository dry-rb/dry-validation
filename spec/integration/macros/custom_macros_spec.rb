# frozen_string_literal: true

RSpec.describe "Defining custom macros" do
  subject(:contract) do
    contract_class.new
  end

  subject(:contract_class) do
    Class.new(Test::BaseContract) do
      schema do
        required(:numbers).array(:integer)
      end
    end
  end

  before do
    class Test::BaseContract < Dry::Validation::Contract; end
  end

  context "using a macro without options" do
    shared_context "a contract with a custom macro" do
      before do
        contract_class.rule(:numbers).validate(:even_numbers)
      end

      it "succeeds with valid input" do
        expect(contract.(numbers: [2, 4, 6])).to be_success
      end

      it "fails with invalid input" do
        expect(contract.(numbers: [1, 2, 3]).errors.to_h).to eql(numbers: ["all numbers must be even"])
      end
    end

    context "using macro from the global registry" do
      before do
        Dry::Validation.register_macro(:even_numbers) do
          key.failure("all numbers must be even") unless values[key_name].all?(&:even?)
        end
      end

      after do
        Dry::Validation::Macros.container._container.delete("even_numbers")
      end

      include_context "a contract with a custom macro"
    end

    context "using macro from contract itself" do
      before do
        Test::BaseContract.register_macro(:even_numbers) do
          key.failure("all numbers must be even") unless values[key_name].all?(&:even?)
        end
      end

      after do
        Test::BaseContract.macros._container.delete("even_numbers")
      end
    end
  end

  context "using a macro with options" do
    before do
      Test::BaseContract.register_macro(:min) do |context:, macro:|
        num = macro.args[0]

        key.failure("must have at least #{num} items") unless values[key_name].size >= num
      end

      contract_class.rule(:numbers).validate(min: 3)
    end

    after do
      Test::BaseContract.macros._container.delete("min")
    end

    it "fails with invalid input" do
      expect(contract.(numbers: [1]).errors.to_h).to eql(numbers: ["must have at least 3 items"])
    end
  end

  context "using a macro with a range option" do
    before do
      Test::BaseContract.register_macro(:in_range) do |macro:|
        range = macro.args[0]

        all_included_in_range = value.all? { |elem| range.include?(elem) }
        key.failure("every item must be included in #{range}") unless all_included_in_range
      end

      contract_class.rule(:numbers).validate(in_range: 1..3)
    end

    after do
      Test::BaseContract.macros._container.delete("in_range")
    end

    it "succeeds with valid input" do
      expect(contract.(numbers: [1, 2, 3])).to be_success
    end

    it "fails with invalid input" do
      expect(contract.(numbers: [1, 2, 6])).to be_failure
    end
  end
end
