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

  it 'correctly responds to messages' do
    expect(schema.({}).messages).to eq(
      age: ["is missing", "must be greater than 18"],
      country: ["is missing", "must be one of: Australia, Poland"],
      email: ["is missing", "must be String"],
    )
  end

  context "structs" do
    subject(:schema) do
      Dry::Validation.Schema do
        key(:person).required(Person)
      end
    end

    class Name < Dry::Types::Value
      attribute :given_name, Dry::Types['strict.string']
      attribute :family_name, Dry::Types['strict.string']
    end

    class Person < Dry::Types::Value
      attribute :name, Name
    end

    it 'handles nested structs' do
      expect(schema.(person: {name: {given_name: 'Tim', family_name: 'Cooper'}})).to be_success
    end

    it 'fails when input is not valid' do
      expect(schema.(person: {name: {given_name: 'Tim'}}).messages).to eq(
        person: {
          name: {
            family_name: ["is missing"],
          },
        },
      )
    end
  end
end
