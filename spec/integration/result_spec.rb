RSpec.describe Dry::Validation::Result do
  subject(:result) { schema.(input) }

  let(:schema) { Dry::Validation.Schema { required(:name).filled(:str?, size?: 2..4) } }

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
        expect(result.messages).to eql(
          name: ['must be filled', 'length must be within 2 - 4']
        )
      end

      it 'with full: true returns full messages' do
        expect(result.messages(full: true)).to eql(
          name: ['name must be filled', 'name length must be within 2 - 4']
        )
      end
    end

    describe '#errors' do
      let(:input) { { name: '' } }

      it 'returns failure messages' do
        expect(result.errors).to eql(name: ['must be filled'])
      end
    end

    describe '#hints' do
      let(:input) { { name: '' } }

      it 'returns hint messages' do
        expect(result.hints).to eql(name: ['length must be within 2 - 4'])
      end
    end

    describe '#message_set' do
      it 'returns message set' do
        expect(result.message_set.to_h).to eql(
          name: ['must be filled', 'length must be within 2 - 4']
        )
      end
    end
  end
end
