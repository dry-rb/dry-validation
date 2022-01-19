# frozen_string_literal: true

RSpec.describe Dry::Validation::Contract, ".rule" do
  subject(:contract) { contract_class.new }

  context "with an array key" do
    let(:contract_class) do
      Class.new(Dry::Validation::Contract) do
        schema do
          required(:tags).array(:hash) do
            required(:name).filled(:string)
          end
        end
      end
    end

    it "allows specifying a rule for array elements" do
      contract_class.rule(:tags) do
        key.failure("must have at least 1 element") if value.empty?
      end

      expect(contract.(tags: []).errors.to_h).to eql(
        tags: ["must have at least 1 element"]
      )
    end

    it "shows the correct error message" do
      contract_class.rule(:tags) do
        key.failure("must have at least 1 element") if value.empty?
      end

      expect(contract.(tags: [], name: "").errors.to_h).to eql(
        tags: ["must have at least 1 element"]
      )

      expect(contract.(tags: [], name: "").errors(full: true).to_h).to eql(
        tags: ["tags must have at least 1 element"]
      )
    end

    context "when using .each macro" do
      it "allows access to index of each member" do
        contract_class.rule(:tags).each do |index:|
          key([:tags, index, :name]).failure("must be Bilbo Bolseiro") unless value[:name] == "Bilbo Bolseiro"
        end

        expect(contract.(tags: [{name: "Parker Peter"}]).errors.to_h).to eql(
          tags: {0 => {name: ["must be Bilbo Bolseiro"]}}
        )
      end
    end
  end
end
