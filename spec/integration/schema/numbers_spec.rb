RSpec.describe Dry::Validation::Schema do
  subject(:schema) do
    Dry::Validation.Schema do
      required(:age).filled(:number?, :int?)
    end
  end

  it 'passes when value is a number and an int' do
    expect(schema.(age: 132)).to be_success
  end

  it 'fails when value is not a number' do
    expect(schema.(age: 'ops').messages).to eql(age: ['must be a number'])
  end

  it 'fails when value is not an integer' do
    expect(schema.(age: 1.0).messages).to eql(age: ['must be an integer'])
  end
end
