# frozen_string_literal: true

RSpec.describe Dry::Validation::Contract, '.macros' do
  subject!(:contract_class) do
    Class.new(parent_class) do
      register_macro(:other_macro) { }
    end
  end

  let(:parent_class) do
    Class.new(Dry::Validation::Contract) do
      register_macro(:check_things) { }
    end
  end

  it 'returns macros container inherited from the parent' do
    expect(contract_class.macros.key?(:check_things)).to be(true)
    expect(contract_class.macros.key?(:other_macro)).to be(true)

    expect(parent_class.macros.key?(:other_macro)).to be(false)
  end

  it 'does not mutate source macro container' do
    expect(parent_class.superclass.macros.key?(:check_things)).to be(false)
  end
end
