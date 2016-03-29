RSpec.describe Dry::Validation::Schema, 'defining schema using dry types' do
  subject(:schema) do
    Dry::Validation.Schema do
      key(:email).required(Email)
      key(:age).maybe(Age)
      key(:country).required(Country)
    end
  end

  before do
    Email = Dry::Types['strict.string']
    Age = Dry::Types['strict.int'].constrained(gt: 18)
    Country = Dry::Types['strict.string'].enum('Australia', 'Poland')
  end

  after do
    Object.send(:remove_const, :Email)
    Object.send(:remove_const, :Age)
    Object.send(:remove_const, :Country)
  end

  it 'passes when input is valid' do
    expect(schema.(email: 'jane@doe', age: 19, country: 'Australia')).to be_success
    expect(schema.(email: 'jane@doe', age: nil, country: 'Poland')).to be_success
  end

  it 'fails when input is not valid' do
    expect(schema.(email: '', age: 19, country: 'New Zealand')).to_not be_success
    expect(schema.(email: 'jane@doe', age: 17)).to_not be_success
    expect(schema.(email: 'jane@doe', age: '19')).to_not be_success
  end
end
