RSpec.describe 'Predicates: Empty' do
  context 'with required' do
    subject(:schema) do
      Dry::Validation.Form do
        required(:foo) { empty? }
      end
    end

    context 'with valid input (array)' do
      let(:input) { { 'foo' => [] } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with valid input (hash)' do
      let(:input) { { 'foo' => {} } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with missing input' do
      let(:input) { {} }

      it 'is not successful' do
        expect(result).to be_failing ['is missing', 'must be empty']
      end
    end

    context 'with nil input' do
      let(:input) { { 'foo' => nil } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with blank input' do
      let(:input) { { 'foo' => '' } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with invalid input' do
      let(:input) { { 'foo' => ['23'] } }

      it 'is not successful' do
        expect(result).to be_failing ['must be empty']
      end
    end
  end

  context 'with optional' do
    subject(:schema) do
      Dry::Validation.Form do
        optional(:foo) { empty? }
      end
    end

    context 'with valid input (array)' do
      let(:input) { { 'foo' => [] } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with valid input (hash)' do
      let(:input) { { 'foo' => {} } }

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
      let(:input) { { 'foo' => nil } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with blank input' do
      let(:input) { { 'foo' => '' } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with invalid input' do
      let(:input) { { 'foo' => ['23'] } }

      it 'is not successful' do
        expect(result).to be_failing ['must be empty']
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).value(:empty?)
          end
        end

        context 'with valid input (array)' do
          let(:input) { { 'foo' => [] } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with valid input (hash)' do
          let(:input) { { 'foo' => {} } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must be empty']
          end
        end

        context 'with nil input' do
          let(:input) { { 'foo' => nil } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => ['23'] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be empty']
          end
        end
      end

      context 'with filled' do
        # it doesn't make sense to ask for a filled key and at the same time assert it's empty
        #
        # Example:
        #
        #   required(:foo).filled(:empty?)
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).maybe(:empty?)
          end
        end

        context 'with valid input (array)' do
          let(:input) { { 'foo' => [] } }

          # See https://github.com/dry-rb/dry-validation/issues/125
          xit 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with valid input (hash)' do
          let(:input) { { 'foo' => {} } }

          # See https://github.com/dry-rb/dry-validation/issues/125
          xit 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must be empty']
          end
        end

        context 'with nil input' do
          let(:input) { { 'foo' => nil } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => ['23'] } }

          # See https://github.com/dry-rb/dry-validation/issues/125#issuecomment-216240035
          xit 'is not successful' do
            expect(result).to be_failing ['must be empty']
          end
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).value(:empty?)
          end
        end

        context 'with valid input (array)' do
          let(:input) { { 'foo' => [] } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with valid input (hash)' do
          let(:input) { { 'foo' => {} } }

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
          let(:input) { { 'foo' => nil } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => ['23'] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be empty']
          end
        end
      end

      context 'with filled' do
        # it doesn't make sense to ask for a filled key and at the same time assert it's empty
        #
        # Example:
        #
        #   optional(:foo).filled(:empty?)
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).maybe(:empty?)
          end
        end

        context 'with valid input (array)' do
          let(:input) { { 'foo' => [] } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with valid input (hash)' do
          let(:input) { { 'foo' => {} } }

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
          let(:input) { { 'foo' => nil } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => ['23'] } }

          # See https://github.com/dry-rb/dry-validation/issues/126
          xit 'is not successful' do
            expect(result).to be_failing ['must be empty']
          end
        end
      end
    end
  end
end
