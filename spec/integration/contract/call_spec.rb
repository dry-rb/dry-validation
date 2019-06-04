# frozen_string_literal: true

require 'dry/validation/contract'

RSpec.describe Dry::Validation::Contract, '#call' do
  subject(:contract) do
    Class.new(Dry::Validation::Contract) do
      def self.name
        'TestContract'
      end

      params do
        required(:email).filled(:string)
        required(:age).filled(:integer)
        optional(:login).maybe(:string, :filled?)
        optional(:password).maybe(:string, min_size?: 10)
        optional(:password_confirmation).maybe(:string)
        optional(:address).hash do
          required(:country).value(:string)
          required(:zip).value(:string)
          optional(:geolocation).hash do
            required(:lon).value(:float)
            required(:lat).value(:float)
          end
        end
      end

      rule(:password) do
        key.failure('is required') if values[:login] && !values[:password]
      end

      rule(:age) do
        key.failure('must be greater or equal 18') if value < 18
      end

      rule(:age) do
        key.failure('must be greater than 0') if value < 0
      end

      rule(address: :zip) do
        address = values[:address]
        if address && address[:country] == 'Russia' && address[:zip] != /\A\d{6}\z/
          key.failure('must have 6 digit')
        end
      end

      rule(address: { geolocation: :lon }) do
        address = values[:address]
        geolocation = address[:geolocation] if address

        if geolocation && !(-180.0...180.0).cover?(geolocation[:lon])
          key.failure('invalid longitude')
        end
      end
    end.new
  end

  it 'applies rule to input processed by the schema' do
    result = contract.(email: 'john@doe.org', age: 19)

    expect(result).to be_success
    expect(result.errors.to_h).to eql({})
  end

  it 'returns rule errors' do
    result = contract.(email: 'john@doe.org', login: 'jane', age: 19)

    expect(result).to be_failure
    expect(result.errors.to_h).to eql(password: ['is required'])
  end

  it "doesn't execute rules when basic checks failed" do
    result = contract.(email: 'john@doe.org', age: 'not-an-integer')

    expect(result).to be_failure
    expect(result.errors.to_h).to eql(age: ['must be an integer'])
  end

  it 'gathers errors from multiple rules for the same key' do
    result = contract.(email: 'john@doe.org', age: -1)

    expect(result).to be_failure
    expect(result.errors.to_h).to eql(age: ['must be greater or equal 18', 'must be greater than 0'])
  end

  it 'builds nested message keys for nested rules' do
    result = contract.(email: 'john@doe.org', age: 20, address: { country: 'Russia', zip: 'abc' })

    expect(result).to be_failure
    expect(result.errors.to_h).to eql(address: { zip: ['must have 6 digit'] })
  end

  it 'builds deeply nested messages for deeply nested rules' do
    result = contract.(
      email: 'john@doe.org',
      age: 20,
      address: {
        country: 'UK', zip: 'irrelevant',
        geolocation: { lon: '365', lat: '78' }
      }
    )

    expect(result).to be_failure
    expect(result.errors.to_h).to eql(address: { geolocation: { lon: ['invalid longitude'] } })
  end
end
