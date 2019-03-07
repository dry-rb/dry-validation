# frozen_string_literal: true

RSpec.describe Dry::Validation::Result do
  describe '#inspect' do
    let(:params) do
      double(:params, message_set: [], to_h: { email: 'jane@doe.org' })
    end

    it 'returns a string representation' do
      result = Dry::Validation::Result.new(params) do |r|
        r.add_error(Dry::Validation::Error.new('not valid', path: :email))
      end

      expect(result.inspect).to eql('#<Dry::Validation::Result{:email=>"jane@doe.org"} errors={:email=>["not valid"]}>')
    end
  end

  describe '#[]' do
    let(:params) do
      double(:params, message_set: [], to_h: {}, key?: false)
    end

    it 'returns nil for missing values' do
      Dry::Validation::Result.new(params) do |r|
        expect(r[:missing]).to be nil
      end
    end
  end
end
