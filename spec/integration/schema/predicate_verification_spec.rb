RSpec.describe 'Verifying predicates in the DSL' do
  it 'raises error when invalid predicate name is used' do
    expect { Dry::Validation.Schema { required(:age).value(filled?: 312) } }
      .to raise_error(ArgumentError, "filled? predicate arity is invalid")

    expect { Dry::Validation.Schema { required(:age) { none? | filled?(312) } } }
      .to raise_error(ArgumentError, "filled? predicate arity is invalid")
  end
end
