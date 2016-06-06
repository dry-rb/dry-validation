RSpec.describe 'Predicates: False' do
  context 'with key' do
    subject(:schema) do
      Dry::Validation.Form do
        required(:foo) { false? }
      end
    end

    context 'with valid input (1)' do
      let(:input) { { 'foo' => '0' } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with valid input (false)' do
      let(:input) { { 'foo' => 'false' } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with missing input' do
      let(:input) { {} }

      it 'is not successful' do
        expect(result).to be_failing ['is missing', 'must be false']
      end
    end

    context 'with nil input' do
      let(:input) { { 'foo' => nil } }

      it 'is not successful' do
        expect(result).to be_failing ['must be false']
      end
    end

    context 'with blank input' do
      let(:input) { { 'foo' => '' } }

      it 'is not successful' do
        expect(result).to be_failing ['must be false']
      end
    end

    context 'with invalid input' do
      let(:input) { { 'foo' => [] } }

      it 'is not successful' do
        expect(result).to be_failing ['must be false']
      end
    end
  end

  context 'with optional' do
    subject(:schema) do
      Dry::Validation.Form do
        optional(:foo) { false? }
      end
    end

    context 'with valid input (1)' do
      let(:input) { { 'foo' => '0' } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with valid input (false)' do
      let(:input) { { 'foo' => 'false' } }

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

      it 'is not successful' do
        expect(result).to be_failing ['must be false']
      end
    end

    context 'with blank input' do
      let(:input) { { 'foo' => '' } }

      it 'is not successful' do
        expect(result).to be_failing ['must be false']
      end
    end

    context 'with invalid input' do
      let(:input) { { 'foo' => [] } }

      it 'is not successful' do
        expect(result).to be_failing ['must be false']
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).value(:false?)
          end
        end

        context 'with valid input (1)' do
          let(:input) { { 'foo' => '0' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with valid input (false)' do
          let(:input) { { 'foo' => 'false' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must be false']
          end
        end

        context 'with nil input' do
          let(:input) { { 'foo' => nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be false']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be false']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => [] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be false']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).filled(:false?)
          end
        end

        context 'with valid input (1)' do
          let(:input) { { 'foo' => '0' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with valid input (false)' do
          let(:input) { { 'foo' => 'false' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must be false']
          end
        end

        context 'with nil input' do
          let(:input) { { 'foo' => nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must be false']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must be false']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => [] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must be false']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).maybe(:false?)
          end
        end

        context 'with valid input (1)' do
          let(:input) { { 'foo' => '0' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with valid input (false)' do
          let(:input) { { 'foo' => 'false' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must be false']
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

          it 'is not successful' do
            expect(result).to be_success
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => [] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be false']
          end
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).value(:false?)
          end
        end

        context 'with valid input (1)' do
          let(:input) { { 'foo' => '0' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with valid input (false)' do
          let(:input) { { 'foo' => 'false' } }

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

          it 'is not successful' do
            expect(result).to be_failing ['must be false']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be false']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => [] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be false']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).filled(:false?)
          end
        end

        context 'with valid input (1)' do
          let(:input) { { 'foo' => '0' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with valid input (false)' do
          let(:input) { { 'foo' => 'false' } }

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

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must be false']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must be false']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => [] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must be false']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).maybe(:false?)
          end
        end

        context 'with valid input (1)' do
          let(:input) { { 'foo' => '0' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with valid input (false)' do
          let(:input) { { 'foo' => 'false' } }

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
            expect(result).to be_success
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => [] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be false']
          end
        end
      end
    end
  end
end
