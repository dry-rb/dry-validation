RSpec.describe 'Dry::Validator' do
  describe 'validate presence' do
    subject! { validator.call(attributes) }

    context 'with option true' do
      let(:validator) do
        Dry::Validator.new(
          name: { presence: true }
        )
      end

      context 'when attribute not present' do
        let(:attributes) do
          { name: '' }
        end

        it 'returns a hash with errors' do
          is_expected.to include(name: [
            { code: 'presence', options: true }
          ])
        end
      end

      context 'when attribute present' do
        let(:attributes) do
          { name: 'Jack' }
        end

        it 'returns an empty hash' do
          is_expected.to be_empty
        end
      end
    end
  end

  describe 'validate length' do
    subject! { validator.call(attributes) }

    context 'with range option' do
      let(:validator) do
        Dry::Validator.new(
          name: { length: 2..5 }
        )
      end

      context 'when attribute not in range' do
        let(:attributes) do
          { name: '' }
        end

        it 'returns a hash with errors' do
          is_expected.to include(name: [
            { code: 'length', options: { min: 2, max: 5 } }
          ])
        end
      end

      context 'when attribute in range' do
        let(:attributes) do
          { name: 'Jill' }
        end

        it 'returns an empty hash' do
          is_expected.to be_empty
        end
      end
    end

    context 'with max option' do
      let(:validator) do
        Dry::Validator.new(
          name: { length: { max: 5 } }
        )
      end

      context 'when attribute too long' do
        let(:attributes) do
          { name: 'Jack Smith' }
        end

        it 'returns a hash with errors' do
          is_expected.to include(name: [
            { code: 'length', options: { max: 5 } }
          ])
        end
      end

      context 'when attribute short enough' do
        let(:attributes) do
          { name: 'Jill' }
        end

        it 'returns an empty hash' do
          is_expected.to be_empty
        end
      end
    end

    context 'with min option' do
      let(:validator) do
        Dry::Validator.new(
          name: { length: { min: 5 } }
        )
      end

      context 'when attribute too short' do
        let(:attributes) do
          { name: 'Jack' }
        end

        it 'returns a hash with errors' do
          is_expected.to include(name: [
            { code: 'length', options: { min: 5 } }
          ])
        end
      end

      context 'when attribute length in range' do
        let(:attributes) do
          { name: 'Jillian' }
        end

        it 'returns an empty hash' do
          is_expected.to be_empty
        end
      end
    end
  end
end
