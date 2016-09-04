RSpec.describe 'Predicates: custom' do
  context 'with custom predicate' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          config.messages_file = 'spec/fixtures/locales/en.yml'

          def email?(current)
            !current.match(/\@/).nil?
          end
        end

        required(:foo) { email? }
      end
    end

    context 'with valid input' do
      let(:input) { { foo: 'test@dry-rb.org' } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with invalid input' do
      let(:input) { { foo: 'test' } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an email']
      end
    end
  end

  context 'with custom predicates as module' do
    subject(:schema) do
      Dry::Validation.Schema do
        configure do
          config.messages_file = 'spec/fixtures/locales/en.yml'
          predicates (Module.new do
            include Dry::Logic::Predicates

            def self.email?(current)
              !current.match(/\@/).nil?
            end
          end)
        end

        required(:foo) { email? }
      end
    end

    context 'with valid input' do
      let(:input) { { foo: 'test@hanamirb.org' } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with invalid input' do
      let(:input) { { foo: 'test' } }

      it 'is successful' do
        expect(result).to be_failing ['must be an email']
      end
    end
  end

  context 'without custom predicate' do
    it 'raises error if try to use an unknown predicate' do
      expect do
        Dry::Validation.Schema do
          required(:foo) { email? }
        end
      end.to raise_error(ArgumentError, '+email?+ is not a valid predicate name')
    end
  end

  context 'with nested validations' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:details).schema do
          configure do
            config.messages_file = 'spec/fixtures/locales/en.yml'

            def odd?(current)
              current.odd?
            end
          end

          required(:foo) { odd? }
        end
      end
    end

    let(:input) { { details: { foo: 2 } } }

    it 'allows groups to define their own custom predicates' do
      expect(result).to_not be_success
      expect(result.messages[:details]).to eq(foo: ['must be odd'])
    end
  end
end
