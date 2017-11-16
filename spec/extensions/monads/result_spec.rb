RSpec.describe Dry::Validation::Result do
  before { Dry::Validation.load_extensions(:monads) }

  let(:schema) { Dry::Validation.Schema { required(:name).filled(:str?, size?: 2..4) } }

  context 'with valid input' do
    let(:input) { { name: 'Jane' } }

    describe '#to_monad' do
      it 'returns a Success value' do
        monad = result.to_monad

        expect(monad).to be_a Dry::Monads::Result
        expect(monad).to be_a_success
        expect(monad.value!).to eql(name: 'Jane')
      end
    end
  end

  context 'with invalid input' do
    let(:input) { { name: '' } }

    describe '#to_monad' do
      it 'returns a Failure value' do
        monad = result.to_monad

        expect(monad).to be_a_failure
        expect(monad.failure).to eql(name: ['must be filled', 'length must be within 2 - 4'])
      end

      it 'returns full messages' do
        monad = result.to_monad(full: true)

        expect(monad).to be_a Dry::Monads::Result
        expect(monad).to be_a_failure
        expect(monad.failure).to eql(name: ['name must be filled', 'name length must be within 2 - 4'])
      end
    end
  end
end
