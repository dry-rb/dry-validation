RSpec.describe 'Predicates: Array' do
  context 'with required' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:foo) { array? { each { int? } } }
      end
    end

    context 'with valid input' do
      let(:input) { { foo: [3] } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with missing input' do
      let(:input) { {} }

      it 'is not successful' do
        expect(result).to be_failing ['is missing']
      end
    end

    context 'with nil input' do
      let(:input) { { foo: nil } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an array']
      end
    end

    context 'with blank input' do
      let(:input) { { foo: '' } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an array']
      end
    end

    context 'with invalid type' do
      let(:input) { { foo: { a: 1 } } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an array']
      end
    end

    context 'with invalid input (integer)' do
      let(:input) { { foo: 4 } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an array']
      end
    end

    context 'with invalid input (array with non-integers)' do
      let(:input) { { foo: [:foo, :bar] } }

      it 'is not successful' do
        expect(result).to be_failing 0 => ['must be an integer'], 1 => ['must be an integer']
      end
    end

    context 'with invalid input (miexed array)' do
      let(:input) { { foo: [1, '2', :bar] } }

      it 'is not successful' do
        expect(result).to be_failing 1 => ['must be an integer'], 2 => ['must be an integer']
      end
    end
  end

  context 'with optional' do
    subject(:schema) do
      Dry::Validation.Schema do
        optional(:foo) { array? { each { int? } } }
      end
    end

    context 'with valid input' do
      let(:input) { { foo: [3] } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with missing input' do
      let(:input) { {} }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with nil input' do
      let(:input) { { foo: nil } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an array']
      end
    end

    context 'with blank input' do
      let(:input) { { foo: '' } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an array']
      end
    end

    context 'with invalid type' do
      let(:input) { { foo: { a: 1 } } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an array']
      end
    end

    context 'with invalid input (integer)' do
      let(:input) { { foo: 4 } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an array']
      end
    end

    context 'with invalid input (array with non-integers)' do
      let(:input) { { foo: [:foo, :bar] } }

      it 'is not successful' do
        expect(result).to be_failing 0 => ['must be an integer'], 1 => ['must be an integer']
      end
    end

    context 'with invalid input (miexed array)' do
      let(:input) { { foo: [1, '2', :bar] } }

      it 'is not successful' do
        expect(result).to be_failing 1 => ['must be an integer'], 2 => ['must be an integer']
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      subject(:schema) do
        Dry::Validation.Schema do
          required(:foo).each(:int?)
        end
      end

      context 'with missing input' do
        let(:input) { {} }

        it 'is not successful' do
          expect(result).to be_failing ['is missing']
        end
      end

      context 'with nil input' do
        let(:input) { { foo: nil } }

        it 'is not successful' do
          expect(result).to be_failing ['must be an array']
        end
      end

      context 'with blank input' do
        let(:input) { { foo: '' } }

        it 'is not successful' do
          expect(result).to be_failing ['must be an array']
        end
      end

      context 'with valid input' do
        let(:input) { { foo: [3] } }

        it 'is successful' do
          expect(result).to be_successful
        end
      end

      context 'with invalid input' do
        let(:input) { { foo: [:bar] } }

        it 'is not successful' do
          expect(result).to be_failing 0 => ['must be an integer']
        end
      end

      context "when using an input_processor" do
        subject(:schema) do
          Dry::Validation.Schema do
            configure do
              config.input_processor = :sanitizer
            end

            required(:foo).each(:int?)
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing']
          end
        end

        context 'with nil input' do
          let(:input) { { foo: nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be an array']
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be an array']
          end
        end

        context 'with valid input' do
          let(:input) { { foo: [3] } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: [:bar] } }

          it 'is not successful' do
            expect(result).to be_failing 0 => ['must be an integer']
          end
        end
      end
    end

    context 'with optional' do
      subject(:schema) do
        Dry::Validation.Schema do
          optional(:foo).each(:int?)
        end
      end

      context 'with missing input' do
        let(:input) { {} }

        it 'is successful' do
          expect(result).to be_successful
        end
      end

      context 'with nil input' do
        let(:input) { { foo: nil } }

        it 'is not successful' do
          expect(result).to be_failing ['must be an array']
        end
      end

      context 'with blank input' do
        let(:input) { { foo: '' } }

        it 'is not successful' do
          expect(result).to be_failing ['must be an array']
        end
      end

      context 'with valid input' do
        let(:input) { { foo: [3] } }

        it 'is successful' do
          expect(result).to be_successful
        end
      end

      context 'with invalid input' do
        let(:input) { { foo: [:bar] } }

        it 'is not successful' do
          expect(result).to be_failing 0 => ['must be an integer']
        end
      end
    end
  end
end
