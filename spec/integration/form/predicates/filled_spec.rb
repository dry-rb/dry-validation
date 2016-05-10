RSpec.describe 'Predicates: Filled' do
  context 'with key' do
    subject(:schema) do
      Dry::Validation.Form do
        required(:foo) { filled? }
      end
    end

    context 'with valid input (array)' do
      let(:input) { { 'foo' => ['23'] } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with valid input (hash)' do
      let(:input) { { 'foo' => { 'bar' => '23' } } }

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
      let(:input) { { 'foo' => nil } }

      it 'is not successful' do
        expect(result).to be_failing ['must be filled']
      end
    end

    context 'with blank input' do
      let(:input) { { 'foo' => '' } }

      it 'is not successful' do
        expect(result).to be_failing ['must be filled']
      end
    end

    context 'with invalid input' do
      let(:input) { { 'foo' => [] } }

      it 'is not successful' do
        expect(result).to be_failing ['must be filled']
      end
    end
  end

  context 'with optional' do
    subject(:schema) do
      Dry::Validation.Form do
        optional(:foo) { filled? }
      end
    end

    context 'with valid input (array)' do
      let(:input) { { 'foo' => ['23'] } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with valid input (hash)' do
      let(:input) { { 'foo' => { 'bar' => '23' } } }

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
        expect(result).to be_failing ['must be filled']
      end
    end

    context 'with blank input' do
      let(:input) { { 'foo' => '' } }

      it 'is not successful' do
        expect(result).to be_failing ['must be filled']
      end
    end

    context 'with invalid input' do
      let(:input) { { 'foo' => [] } }

      it 'is not successful' do
        expect(result).to be_failing ['must be filled']
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).value(:filled?)
          end
        end

        context 'with valid input (array)' do
          let(:input) { { 'foo' => ['23'] } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with valid input (hash)' do
          let(:input) { { 'foo' => { 'bar' => '23' } } }

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
          let(:input) { { 'foo' => nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => [] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).filled
          end
        end

        context 'with valid input (array)' do
          let(:input) { { 'foo' => ['23'] } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with valid input (hash)' do
          let(:input) { { 'foo' => { 'bar' => '23' } } }

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
          let(:input) { { 'foo' => nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => [] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).maybe(:filled?)
          end
        end

        context 'with valid input (array)' do
          let(:input) { { 'foo' => ['23'] } }

          # See: https://github.com/dry-rb/dry-validation/issues/130
          xit 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with valid input (hash)' do
          let(:input) { { 'foo' => { 'bar' => '23' } } }

          # See: https://github.com/dry-rb/dry-validation/issues/130#issuecomment-216463196
          xit 'is successful' do
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
          let(:input) { { 'foo' => nil } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          # See: https://github.com/dry-rb/dry-validation/issues/130#issuecomment-216463576
          xit 'is not successful' do
            expect(result).to be_failing ['must be filled']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => [] } }

          # See: https://github.com/dry-rb/dry-validation/issues/130#issuecomment-216463925
          xit 'is not successful' do
            expect(result).to be_failing ['must be filled']
          end
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).value(:filled?)
          end
        end

        context 'with valid input (array)' do
          let(:input) { { 'foo' => ['23'] } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with valid input (hash)' do
          let(:input) { { 'foo' => { 'bar' => '23' } } }

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
            expect(result).to be_failing ['must be filled']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => [] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).filled
          end
        end

        context 'with valid input (array)' do
          let(:input) { { 'foo' => ['23'] } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with valid input (hash)' do
          let(:input) { { 'foo' => { 'bar' => '23' } } }

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
            expect(result).to be_failing ['must be filled']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => [] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).maybe(:filled?)
          end
        end

        context 'with valid input (array)' do
          let(:input) { { 'foo' => ['23'] } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with valid input (hash)' do
          let(:input) { { 'foo' => { 'bar' => '23' } } }

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

          # See: https://github.com/dry-rb/dry-validation/issues/130#issuecomment-216464277
          xit 'is not successful' do
            expect(result).to be_failing ['must be filled']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => [] } }

          # See: https://github.com/dry-rb/dry-validation/issues/130#issuecomment-216464499
          xit 'is not successful' do
            expect(result).to be_failing ['must be filled']
          end
        end
      end
    end
  end
end
