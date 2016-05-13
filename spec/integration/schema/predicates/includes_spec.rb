RSpec.describe 'Predicates: Includes' do
  context 'with required' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:foo) { includes?(1) }
      end
    end

    context 'with valid input' do
      let(:input) { { foo: [1, 2, 3] } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with missing input' do
      let(:input) { {} }

      it 'is not successful' do
        expect(result).to be_failing ['is missing', 'must include 1']
      end
    end

    context 'with nil input' do
      let(:input) { { foo: nil } }

      it 'is not successful' do
        expect(result).to be_failing ['must include 1']
      end
    end

    context 'with blank input' do
      let(:input) { { foo: '' } }

      it 'is not successful' do
        expect(result).to be_failing ['must include 1']
      end
    end

    context 'with invalid input' do
      let(:input) { { foo: [2, 3, 4] } }

      it 'is not successful' do
        expect(result).to be_failing ['must include 1']
      end
    end
  end

  context 'with optional' do
    subject(:schema) do
      Dry::Validation.Schema do
        optional(:foo) { includes?(1) }
      end
    end

    context 'with valid input' do
      let(:input) { { foo: [1, 2, 3] } }

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
        expect(result).to be_failing ['must include 1']
      end
    end

    context 'with blank input' do
      let(:input) { { foo: '' } }

      it 'is not successful' do
        expect(result).to be_failing ['must include 1']
      end
    end

    context 'with invalid input' do
      let(:input) { { foo: [2, 3, 4] } }

      it 'is not successful' do
        expect(result).to be_failing ['must include 1']
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Schema do
            required(:foo).value(includes?: 1)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: [1, 2, 3] } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must include 1']
          end
        end

        context 'with nil input' do
          let(:input) { { foo: nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must include 1']
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is successful' do
            expect(result).to be_failing ['must include 1']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: [2, 3, 4] } }

          it 'is not successful' do
            expect(result).to be_failing ['must include 1']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Schema do
            required(:foo).filled(includes?: 1)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: [1, 2, 3] } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must include 1']
          end
        end

        context 'with nil input' do
          let(:input) { { foo: nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must include 1']
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must include 1']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: [2, 3, 4] } }

          it 'is not successful' do
            expect(result).to be_failing ['must include 1']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Schema do
            required(:foo).maybe(includes?: 1)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: [1, 2, 3] } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must include 1']
          end
        end

        context 'with nil input' do
          let(:input) { { foo: nil } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is successful' do
            expect(result).to be_failing ['must include 1']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: [2, 3, 4] } }

          it 'is not successful' do
            expect(result).to be_failing ['must include 1']
          end
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Schema do
            optional(:foo).value(includes?: 1)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: [1, 2, 3] } }

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
            expect(result).to be_failing ['must include 1']
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is successful' do
            expect(result).to be_failing ['must include 1']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: [2, 3, 4] } }

          it 'is not successful' do
            expect(result).to be_failing ['must include 1']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Schema do
            optional(:foo).filled(includes?: 1)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: [1, 2, 3] } }

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
            expect(result).to be_failing ['must be filled', 'must include 1']
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must include 1']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: [2, 3, 4] } }

          it 'is not successful' do
            expect(result).to be_failing ['must include 1']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Schema do
            optional(:foo).maybe(includes?: 1)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: [1, 2, 3] } }

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

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must include 1']
          end
        end

        context 'with invalid input' do
          let(:input) { { foo: [2, 3, 4] } }

          it 'is not successful' do
            expect(result).to be_failing ['must include 1']
          end
        end
      end
    end
  end
end
