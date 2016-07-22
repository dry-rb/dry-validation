RSpec.describe Dry::Validation::Result do
  subject(:result) { schema.(input) }

  let(:schema) { Dry::Validation.Schema { required(:name).filled(:str?) } }

  context 'with valid input' do
    let(:input) { { name: 'Jane' } }

    it 'is successful' do
      expect(result).to be_successful
    end

    it 'is not a failure' do
      expect(result).to_not be_failure
    end

    it 'coerces to validated hash' do
      expect(Hash(result)).to eql(name: 'Jane')
    end

    describe '#messages' do
      it 'returns an empty hash' do
        expect(result.messages).to be_empty
      end

      it 'returns same hash all the time' do
        expect(result.messages).to be(result.messages)
      end
    end
  end

  context 'with invalid input' do
    let(:input) { { name: '' } }

    it 'is not successful' do
      expect(result).to_not be_successful
    end

    it 'is failure' do
      expect(result).to be_failure
    end

    it 'coerces to validated hash' do
      expect(Hash(result)).to eql(name: '')
    end

    describe '#messages' do
      it 'returns a hash with error messages' do
        expect(result.messages).to eql(name: ['must be filled'])
      end

      it 'returns same hash all the time' do
        expect(result.messages).to be(result.messages)
      end

      it 'with full: true returns full messages' do
        expect(result.messages(full: true)).to eql(name: ['name must be filled'])
      end
    end

    describe '#message_set' do
      it 'returns message set' do
        expect(result.message_set.to_h).to eql(name: ['must be filled'])
      end
    end
  end
end
