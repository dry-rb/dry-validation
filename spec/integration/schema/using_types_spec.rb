RSpec.describe Dry::Validation::Schema, 'defining schema using dry types' do
  subject(:schema) do
    Dry::Validation.Schema do
      key(:email).required(Email)
      key(:age).maybe(Age)
      key(:country).required(Country)
      optional(:admin).maybe(AdminBit)
    end
  end

  before do
    Email = Dry::Types['strict.string']
    Age = Dry::Types['strict.int'].constrained(gt: 18)
    Country = Dry::Types['strict.string'].enum('Australia', 'Poland')
    AdminBit = Dry::Types['strict.bool']
  end

  after do
    Object.send(:remove_const, :Email)
    Object.send(:remove_const, :Age)
    Object.send(:remove_const, :Country)
    Object.send(:remove_const, :AdminBit)
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

  it 'fails when sum-type rule did not pass' do
    expect(schema.(email: 'jane@doe', age: 19, country: 'Australia', admin: 'foo').messages).to eql(
      admin: ['must be FalseClass', 'must be TrueClass']
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
      expect(schema.(person: { name: { given_name: 'Tim', family_name: 'Cooper' } })).to be_success
    end

    it 'fails when input is not valid' do
      expect(schema.(person: {name: {given_name: 'Tim'}}).messages).to eq(
        person: { name: { family_name: ["is missing"] } }
      )
    end
  end

  context 'custom coercions' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure { config.input_processor = :sanitizer }

        key(:email).required(Dry::Types['strict.string'].constructor(&:strip))
      end
    end

    it 'applies custom types to input prior validation' do
      result = schema.(email: ' jane@doe.org  ')

      expect(result).to be_success
      expect(result.to_h).to eql(email: 'jane@doe.org')
    end
  end

  context 'custom types' do
    subject(:schema) do
      Dry::Validation.Form do
        key(:quantity).required(Dry::Types['strict.int'].constrained(gt: 1))
        key(:percentage).required(Dry::Types['strict.decimal'].constrained(gt: 0, lt: 1))
        key(:switch).required(Dry::Types['strict.bool'])
      end
    end

    it 'applies custom types to input prior validation' do
      result = schema.(quantity: '2', percentage: '0.5', switch: '0')

      expect(result).to be_success
      expect(result.to_h).to eql(quantity: 2, percentage: BigDecimal('0.5'), switch: false)
    end
  end
end
