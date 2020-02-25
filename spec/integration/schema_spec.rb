# frozen_string_literal: true

require 'dry/validation/schema_ext'

# TODO move Schema#compose tests to dry-schema
RSpec.describe Dry::Schema do
  subject(:schema) { Test::Schema }

  before do
    module Test
      EmailSchema = Dry::Schema.Params do
        required(:email).filled(:string)
      end

      AgeSchema = Dry::Schema.Params do
        required(:age).filled(:integer, gt?: 17)
      end
    end
  end

  describe 'composed schema' do
    before do
      Test::Schema = Dry::Schema.Params do
        compose Test::EmailSchema, Test::AgeSchema
      end
    end

    it 'validates input' do
      result = subject.call(age: '17')
      expect(result).to be_failure
      expect(result.errors.to_h).to eq(age: ["must be greater than 17"],
                                       email: ["is missing"])

      result = subject.call(age: '18', email: 'jim@email.com')
      expect(result).to be_success
    end
  end

  describe 'compose schemas at nested locations' do
    before do
      Test::Schema = Dry::Schema.Params do
        required(:account).hash do
          required(:primary).hash do
            compose Test::EmailSchema, Test::AgeSchema
          end

          required(:secondary).array(:hash) do
            compose Test::EmailSchema, Test::AgeSchema
          end
        end
      end
    end

    it 'validates input' do
      result = subject.call({})
      expect(result).to be_failure
      expect(result.errors.to_h).to eq(account: ["is missing"])

      result = subject.call(account: {
        primary: { age: '19' },
        secondary: [{ age: '17', email: 'nik@email.com' }] })
      expect(result).to be_failure
      expect(result.errors.to_h).to \
        eq(account: {
            primary: { email: ["is missing"] },
            secondary: { 0 => { age: ["must be greater than 17"] } } })

      result = subject.call(account: {
        primary: { age: '19', email: 'jon@email.com' },
        secondary: [{ age: '18', email: 'nik@email.com' }] })
      expect(result).to be_success
    end
  end

  describe 'composed of schemas with different processor types' do
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
end
