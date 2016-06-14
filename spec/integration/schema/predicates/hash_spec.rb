RSpec.describe 'Predicates: hash?' do
  shared_examples 'hash predicate' do
    context 'with valid input' do
      let(:input) { { foo: { a: 1 } } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with nil input' do
      let(:input) { { foo: nil } }

      it 'is not successful' do
        expect(result).to be_failing ['must be a hash']
      end
    end

    context 'with blank input' do
      let(:input) { { foo: '' } }

      it 'is not successful' do
        expect(result).to be_failing ['must be a hash']
      end
    end

    context 'with invalid type' do
      let(:input) { { foo: 1 } }

      it 'is not successful' do
        expect(result).to be_failing ['must be a hash']
      end
    end
  end

  context 'with required' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:foo) { hash? }
      end
    end

    it_behaves_like 'hash predicate' do
      context 'with missing input' do
        let(:input) { {} }

        it 'is not successful' do
          expect(result).to be_failing ['is missing']
        end
      end
    end
  end

  context 'with optional' do
    subject(:schema) do
      Dry::Validation.Schema do
        optional(:foo) { hash? }
      end
    end

    it_behaves_like 'hash predicate' do
      let(:input) { {} }

      it 'is successful when key is no present' do
        expect(result).to be_successful
      end
    end
  end
end
