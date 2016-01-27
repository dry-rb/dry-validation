RSpec.describe 'Schema::Form / Default key behavior' do
  subject(:validate) { schema.new }

  let(:schema) do
    Class.new(Dry::Validation::Schema::Form) do
      key(:name).required
      key(:age).required(:int?)
      optional(:address).required
    end
  end

  it 'applies filled? predicate by default' do
    expect(validate.('name' => 'jane', 'age' => '21').params).to eql(
      name: 'jane', age: 21
    )
  end

  it 'applies filled? predicate by default to optional key' do
    expect(validate.('name' => 'jane', 'age' => '21', 'address' => 'Earth').params).to eql(
      name: 'jane', age: 21, address: 'Earth'
    )
  end
end
