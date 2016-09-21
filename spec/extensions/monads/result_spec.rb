RSpec.describe Dry::Validation::Result do
  before { Dry::Validation.load_extensions(:monads) }

  let(:schema) { Dry::Validation.Schema { required(:name).filled(:str?, size?: 2..4) } }

  context 'with valid input' do
    let(:input) { { name: 'Jane' } }

    describe '#to_either' do
      it 'returns a Right instance' do
        either = result.to_either

        expect(either).to be_right
        expect(either.value).to eql(name: 'Jane')
      end
    end
  end

  context 'with invalid input' do
    let(:input) { { name: '' } }

    describe '#to_either' do
      it 'returns a Left instance' do
        either = result.to_either

        expect(either).to be_left
        expect(either.value).to eql(name: ['must be filled', 'length must be within 2 - 4'])
      end

      it 'returns full messages' do
        either = result.to_either(full: true)

        expect(either).to be_left
        expect(either.value).to eql(name: ['name must be filled', 'name length must be within 2 - 4'])
      end
    end
  end
end
