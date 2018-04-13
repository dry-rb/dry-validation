RSpec.describe Dry::Validation::Schema, 'defining schema using dry struct' do
  before do
    Dry::Validation.load_extensions(:struct)
  end

  subject(:schema) do
    Dry::Validation.Schema do
      required(:person).filled(Test::Person)
    end
  end

  before do
    class Test::Name < Dry::Struct::Value
      attribute :given_name, Dry::Types['strict.string']
      attribute :family_name, Dry::Types['strict.string']
    end

    class Test::Person < Dry::Struct::Value
      attribute :name, Test::Name
      attribute :numbers, Dry::Types['strict.array'].of(Dry::Types['strict.int'])
    end
  end

  it 'handles nested structs' do
    expect(
      schema.call(
        person: {
          name: { given_name: 'Tim', family_name: 'Cooper'},
          numbers: [123, 345]
        }
      )
    ).to be_success
  end

  it 'handles empty arrays in nested structs' do
    expect(
      schema.call(
        person: {
          name: { given_name: 'Tim', family_name: 'Cooper'},
          numbers: []
        }
      )
    ).to be_success
  end

  it 'fails when input is not valid' do
    expect(
      schema.call(
        person: {
          name: { given_name: 'Tim' },
          numbers: [123, 'wrong']
        }
      ).messages
    ).to eq(
      person: {
        name: { family_name: ['is missing', 'must be String'] },
        numbers: { 1 => ['must be Integer'] }
      }
    )
  end
end
