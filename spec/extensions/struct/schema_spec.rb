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
    end
  end

  it 'handles nested structs' do
    expect(schema.call(person: { name: { given_name: 'Tim', family_name: 'Cooper' } })).to be_success
  end

  it 'fails when input is not valid' do
    expect(schema.call(person: { name: { given_name: 'Tim' } }).messages).to eq(
      person: { name: { family_name: ['is missing', 'must be String'] } }
    )
  end

  context 'when nested struct fields are omittable' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:book).schema(Test::Book)
      end
    end

    before do
      class Test::Author < Dry::Struct::Value
        attribute :name, Dry::Types['strict.string']
        attribute :age, Dry::Types['strict.integer'].meta(omittable: true)
      end

      class Test::Book < Dry::Struct::Value
        attribute :author, Test::Author.meta(omittable: true)
      end
    end

    it 'does not fail when omittable fields are omitted' do
      expect(schema.call(book: {})).to be_success
    end

    it 'does not fail when nested omittable fields are omitted' do
      expect(schema.call(book: { author: { name: 'Toby' } })).to be_success
    end
  end

  context 'when nested struct field is arrays of structs' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:category).schema(Test::Category)
      end
    end

    before do
      class Test::Product < Dry::Struct::Value
        attribute :name, Dry::Types['strict.string']
        attribute :sku, Dry::Types['strict.integer']
        attribute :size, Dry::Types['strict.string'].meta(omittable: true)
      end

      class Test::Category < Dry::Struct::Value
        attribute :products, Dry::Types['strict.array'].of(Test::Product)
      end
    end

    it 'allows an empty array' do
      expect(schema.call(category: { products: [] })).to be_success
    end

    it 'does not fail when omittable fields are omitted' do
      expect(
        schema.call(
          category: {
            products: [
              {
                name: 'Thing',
                sku: 123
              }
            ]
          }
        )
      ).to be_success
    end

    it 'fails when nested array member schema input is invalid' do
      expect(
        schema.call(
          category: {
            products: [
              {
                name: 'Thing',
                sku: 123,
                size: 1
              }
            ]
          }
        ).messages
      ).to eq(
        category: {
          products: {
            0 => {
              size: [
                'must be String'
              ]
            }
          }
        }
      )
    end
  end

  context 'when nested struct field is arrays of structs' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:package).schema(Test::Package)
      end
    end

    before do
      class Test::PriceSet < Dry::Struct::Value
        attribute :prices, Dry::Types['strict.array'].of(Dry::Types['strict.integer'])
      end

      class Test::Package < Dry::Struct::Value
        attribute :price_set, Test::PriceSet
      end
    end

    it 'succeeds when input is valid' do
      expect(schema.call(package: { price_set: { prices: [1, 2] } })).to be_success
    end

    it 'fails when nested array member is not valid type' do
      expect(
        schema.call(
          package: {
            price_set: {
              prices: ['1']
            }
          }
        ).messages
      ).to eq(
        package: {
          price_set: {
            prices: {
              0 => [
                'must be Integer'
              ]
            }
          }
        }
      )
    end
  end
end
