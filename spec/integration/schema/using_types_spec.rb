RSpec.describe Dry::Validation::Schema, 'defining schema using dry types' do
  subject(:schema) do
    Dry::Validation.Schema do
      required(:email).filled(Email)
      required(:age).maybe(Age)
      required(:country).filled(Country)
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
    expect(schema.call(email: 'jane@doe', age: 19, country: 'Australia')).to be_success
    expect(schema.call(email: 'jane@doe', age: nil, country: 'Poland')).to be_success
  end

  it 'fails when input is not valid' do
    expect(schema.call(email: '', age: 19, country: 'New Zealand')).to_not be_success
    expect(schema.call(email: 'jane@doe', age: 17)).to_not be_success
    expect(schema.call(email: 'jane@doe', age: '19')).to_not be_success
  end

  it 'correctly responds to messages' do
    expect(schema.call({}).messages).to eq(
      age: ['is missing', 'must be Integer', 'must be greater than 18'],
      country: ['is missing', 'must be String', 'must be one of: Australia, Poland'],
      email: ['is missing', 'must be String']
    )
  end

  it 'fails when sum-type rule did not pass' do
    result = schema.call(email: 'jane@doe', age: 19, country: 'Australia', admin: 'foo')
    expect(result.messages).to eql(
      admin: ['must be TrueClass or must be FalseClass']
    )
  end

  context 'custom coercions' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure { config.input_processor = :sanitizer }

        required(:email).filled(Dry::Types['strict.string'].constructor(&:strip))
      end
    end

    it 'applies custom types to input prior validation' do
      result = schema.call(email: ' jane@doe.org  ')

      expect(result).to be_success
      expect(result.to_h).to eql(email: 'jane@doe.org')
    end
  end

  context 'custom types' do
    subject(:schema) do
      Dry::Validation.Form do
        required(:quantity).filled(Dry::Types['strict.int'].constrained(gt: 1))
        required(:percentage).filled(Dry::Types['strict.decimal'].constrained(gt: 0, lt: 1))
        required(:switch).filled(Dry::Types['strict.bool'])
      end
    end

    it 'applies custom types to input prior validation' do
      result = schema.call(quantity: '2', percentage: '0.5', switch: '0')

      expect(result).to be_success
      expect(result.to_h).to eql(quantity: 2, percentage: BigDecimal('0.5'), switch: false)
    end
  end

  context 'with a nested schema' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:address).schema do
          zip = Dry::Types['strict.string'].constrained(format: /\A[0-9]{5}(-[0-9]{4})?\z/)

          required(:zip).filled(zip)
        end
      end
    end

    it 'returns success for valid input' do
      expect(schema.(address: { zip: '12321' })).to be_success
    end

    it 'returns failure for invalid input' do
      expect(schema.(address: { zip: '12-321' })).to be_failure
    end

    it 'returns messages for invalid input' do
      expect(schema.(address: nil).messages).to eql(
        address: ['must be a hash']
      )
    end

    it 'returns error messages for invalid input' do
      expect(schema.(address: {}).errors).to eql(
        address: { zip: ['is missing'] }
      )

      expect(schema.(address: { zip: '12-321' }).errors).to eql(
        address: { zip: ['is in invalid format'] }
      )
    end
  end

  context 'with each' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:countries).each(Country)
      end
    end

    it 'applies type constraint checks to each element' do
      result = schema.call(countries: %w(Poland Australia))

      expect(result).to be_success
      expect(result.to_h).to eql(countries: %w(Poland Australia))
    end
  end
end
