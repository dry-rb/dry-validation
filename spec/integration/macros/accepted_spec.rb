# frozen_string_literal: true

RSpec.describe Dry::Validation::Macros, ":acceptance" do
  subject(:contract) do
    Dry::Validation::Contract.build do
      schema do
        required(:terms).value(:bool)
      end

      rule(:terms).validate(:acceptance)
    end
  end

  it "succeeds when value is true" do
    expect(contract.(terms: true)).to be_success
  end

  it "fails when value is not true" do
    expect(contract.(terms: false).errors.to_h).to eql(terms: ["must accept terms"])
  end
end
