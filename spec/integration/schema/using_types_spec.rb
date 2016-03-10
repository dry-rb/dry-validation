RSpec.describe Dry::Validation::Schema, 'defining schema using dry types' do
  subject(:schema) do
    Dry::Validation.Schema do
      key(:email).required(Email)
      key(:age).maybe(Age)
    end
  end

  before do
    Email = Dry::Types['strict.string']
    Age = Dry::Types['strict.int'].constrained(gt: 18)
  end

  after do
    Object.send(:remove_const, :Email)
    Object.send(:remove_const, :Age)
  end

  it 'passes when input is valid' do
    expect(schema.(email: 'jane@doe', age: 19)).to be_success
    expect(schema.(email: 'jane@doe', age: nil)).to be_success
  end

  it 'fails when input is not valid' do
    expect(schema.(email: 'jane@doe', age: 17)).to_not be_success
  end
end
