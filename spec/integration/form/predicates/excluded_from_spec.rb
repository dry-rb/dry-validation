RSpec.describe 'Predicates: Excluded From' do
  context 'with required' do
    subject(:schema) do
      Dry::Validation.Form do
        required(:foo) { excluded_from?(%w(1 3 5)) }
      end
    end

    context 'with valid input' do
      let(:input) { { 'foo' => '2' } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with missing input' do
      let(:input) { {} }

      it 'is not successful' do
        expect(result).to be_failing ['is missing', 'must not be one of: 1, 3, 5']
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

    context 'with invalid type' do
      let(:input) { { 'foo' => { 'a' => '1' } } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with invalid input' do
      let(:input) { { 'foo' => '5' } }

      it 'is not successful' do
        expect(result).to be_failing ['must not be one of: 1, 3, 5']
      end
    end
  end

  context 'with optional' do
    subject(:schema) do
      Dry::Validation.Form do
        optional(:foo) { excluded_from?(%w(1 3 5)) }
      end
    end

    context 'with valid input' do
      let(:input) { { 'foo' => '2' } }

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

    context 'with invalid type' do
      let(:input) { { 'foo' => { 'a' => '1' } } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with invalid input' do
      let(:input) { { 'foo' => '5' } }

      it 'is not successful' do
        expect(result).to be_failing ['must not be one of: 1, 3, 5']
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).value(excluded_from?: %w(1 3 5))
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => '2' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must not be one of: 1, 3, 5']
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

        context 'with invalid type' do
          let(:input) { { 'foo' => { 'a' => '1' } } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => '5' } }

          it 'is not successful' do
            expect(result).to be_failing ['must not be one of: 1, 3, 5']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).filled(excluded_from?: %w(1 3 5))
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => '2' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must not be one of: 1, 3, 5']
          end
        end

        context 'with nil input' do
          let(:input) { { 'foo' => nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must not be one of: 1, 3, 5']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must not be one of: 1, 3, 5']
          end
        end

        context 'with invalid type' do
          let(:input) { { 'foo' => { 'a' => '1' } } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => '5' } }

          it 'is not successful' do
            expect(result).to be_failing ['must not be one of: 1, 3, 5']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).maybe(excluded_from?: %w(1 3 5))
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => '2' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must not be one of: 1, 3, 5']
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

        context 'with invalid type' do
          let(:input) { { 'foo' => { 'a' => '1' } } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => '5' } }

          it 'is not successful' do
            expect(result).to be_failing ['must not be one of: 1, 3, 5']
          end
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).value(excluded_from?: %w(1 3 5))
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => '2' } }

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

        context 'with invalid type' do
          let(:input) { { 'foo' => { 'a' => '1' } } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => '5' } }

          it 'is not successful' do
            expect(result).to be_failing ['must not be one of: 1, 3, 5']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).filled(excluded_from?: %w(1 3 5))
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => '2' } }

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
            expect(result).to be_failing ['must be filled', 'must not be one of: 1, 3, 5']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must not be one of: 1, 3, 5']
          end
        end

        context 'with invalid type' do
          let(:input) { { 'foo' => { 'a' => '1' } } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => '5' } }

          it 'is not successful' do
            expect(result).to be_failing ['must not be one of: 1, 3, 5']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).maybe(excluded_from?: %w(1 3 5))
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => '2' } }

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

        context 'with invalid type' do
          let(:input) { { 'foo' => { 'a' => '1' } } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => '5' } }

          it 'is not successful' do
            expect(result).to be_failing ['must not be one of: 1, 3, 5']
          end
        end
      end
    end
  end
end
