# frozen_string_literal: true

require 'dry/validation/composition/result'

RSpec.describe Dry::Validation::Composition::Result do
  subject(:result) do
    Dry::Validation::Composition::Result.new do |result|
      results.each { |r| result.add_result(r) }
    end
  end

  let(:results) { [] }

  let(:email_schema) do
    Dry::Schema.define { required(:email).value(:string, format?: /@/) }
  end

  let(:name_contract) do
    Dry::Validation.Contract do
      params { required(:name).filled(:string) }

      rule(:name) { base.failure('You must be Jim') if value != 'Jim' }
    end
  end

  context 'with no results' do
    it { is_expected.to be_success }

    it '#to_h returns an empty hash' do
      expect(result.to_h).to eq({})
    end
  end

  context 'with 2 successful results' do
    let(:results) do
      [email_schema.(email: 'foo@bar'), name_contract.(name: 'Jim')]
    end

    it { is_expected.to be_success }

    it '#to_h has the values from both results' do
      expect(result.to_h).to eq(email: 'foo@bar', name: 'Jim')
    end
  end

  context '1 successful result, 1 failure result' do
    let(:results) do
      [email_schema.(email: 'fred@email.com'), name_contract.(name: 'Fred')]
    end

    it { is_expected.to be_failure }

    it '#to_h has the values from both results' do
      expect(result.to_h).to eq(email: 'fred@email.com', name: 'Fred')
    end

    it 'has the errors from the failure' do
      expect(result.errors.to_h).to eq(nil => ['You must be Jim'])
      expect(result.errors(full: true).map(&:to_s)).to eq ['You must be Jim']
    end
  end

  context '2 failure results' do
    let(:results) do
      [email_schema.(email: 'nope'), name_contract.(name: 'Jade')]
    end

    it { is_expected.to be_failure }

    it '#to_h has the values from both results' do
      expect(result.to_h).to eq(email: 'nope', name: 'Jade')
    end

    it 'has the errors from the failures' do
      expect(result.errors(full: true).map(&:to_s))
        .to eq ['email is in invalid format', 'You must be Jim']

      expect(result.errors.to_h).to eq(email: ['is in invalid format'],
                                       nil => ['You must be Jim'])
    end
  end

  context 'multiple failure results for the same key' do
    let(:name_length_schema) do
      Dry::Schema.define { required(:name).value(:string, min_size?: 3) }
    end

    let(:results) do
      [name_contract.(name: ''), name_length_schema.(name: '')]
    end

    it 'concatenates the errors at the key' do
      expect(result.errors.to_h).to eq(name: ['must be filled', 'size cannot be less than 3'])
    end
  end

  context 'results at different paths' do
    subject(:result) do
      Dry::Validation::Composition::Result.new do |result|
        result.add_result email_schema.(email: 'smudger')
        result.add_result email_schema.(email: 'paino'), :keeper
        result.add_result email_schema.(email: 'gary'), 'leg.fine'
        result.add_result email_schema.(email: 'cummins'), [:leg, :square, :deep]
      end
    end

    it '#to_h has values at the specified paths' do
      expect(result.to_h)
        .to eq(email: 'smudger',
               keeper: { email: 'paino' },
               leg: { fine: { email: 'gary' },
                      square: { deep: { email: 'cummins' } } })
    end

    it '#errors has messages at the specified paths' do
      expect(result.errors.to_h)
        .to eq(email: ['is in invalid format'],
               keeper: { email: ['is in invalid format'] },
               leg: { fine: { email: ['is in invalid format'] },
                      square: { deep: { email: ['is in invalid format'] } } })
    end
  end
end
