# frozen_string_literal: true

require 'dry/validation/schema_ext'

# TODO move Schema#compose tests to dry-schema
RSpec.describe Dry::Schema do
  subject(:schema) { Test::Schema }

  before do
    module Test
      EmailSchema = Dry::Schema.Params { required(:email).filled(:string) }
      NameSchema = Dry::Schema.Params { required(:name).filled(:string) }
    end
  end

  describe 'composed schema' do
    before do
      Test::Schema = Dry::Schema.Params do
        compose Test::EmailSchema, Test::NameSchema
      end
    end

    it 'validates input' do
      result = subject.call(name: 'Jim')
      expect(result).to be_failure
      expect(result.errors.to_h).to eq(email: ['is missing'])

      result = subject.call(name: 'Jim', email: 'jim@email.com')
      expect(result).to be_success
    end
  end

  describe 'composed + own rules' do
    before do
      Test::Schema = Dry::Schema.Params do
        compose Test::EmailSchema
        compose Test::NameSchema
        required(:city).filled(:string)
      end
    end

    it 'validates input' do
      result = subject.call(name: 'Jim')
      expect(result).to be_failure
      expect(result.errors.to_h).to eq(city: ['is missing'],
                                       email: ['is missing'])

      result = subject.call(city: 'Ham', name: 'Jim', email: 'jim@email.com')
      expect(result).to be_success
    end
  end

  describe 'composed of incompatible schemas' do
    it 'raises Dry::Schema::InvalidSchemaError with a useful message' do
      expect do
        Dry::Schema.JSON do
          compose Test::EmailSchema
        end
      end.to raise_error Dry::Schema::InvalidSchemaError,
        <<-STR.gsub(/\s+/,' ').chomp
          schema compositions must have the same processor type as the
          composing schema (Dry::Schema::JSON), but they were
          [Dry::Schema::Params]
        STR
    end
  end

  describe 'composed at a path' do
    before do
      Test::Schema = Dry::Schema.Params do
        required(:contact).hash do
          compose Test::EmailSchema
          compose Test::NameSchema
        end
      end
    end

    it 'validates input' do
      result = subject.call(contact: { name: 'Jim' })
      expect(result).to be_failure
      expect(result.errors.to_h).to eq(contact: { email: ['is missing'] })

      result = subject.call(contact: { name: 'Jim', email: 'jim@email.com' })
      expect(result).to be_success
    end
  end

  describe 'composed in array' do
    before do
      Test::Schema = Dry::Schema.Params do
        required(:contacts).array(:hash) do
          compose Test::EmailSchema
          compose Test::NameSchema
        end
      end
    end

    it 'validates input' do
      result = subject.call(contacts: [{ name: 'Jim', email: 'jim@email.com' },
                                       { name: 'Nik' }])

      expect(result).to be_failure
      expect(result.errors.to_h)
        .to eq(contacts: { 1 => { email: ["is missing"] } })

      result = subject.call(contacts: [{ name: 'Jim', email: 'jim@email.com' },
                                       { name: 'Nik', email: 'nik@email.com' }])
      expect(result).to be_success
    end
  end
end
