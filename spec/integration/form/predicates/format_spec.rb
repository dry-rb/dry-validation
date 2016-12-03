RSpec.describe 'Predicates: Format' do
  context 'with required' do
    subject(:schema) do
      Dry::Validation.Form do
        required(:foo) { str? & format?(/bar/) }
      end
    end

    context 'with valid input' do
      let(:input) { { 'foo' => 'bar baz' } }

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
        expect(result).to be_failing ['must be a string']
      end
    end

    context 'with blank input' do
      let(:input) { { 'foo' => '' } }

      it 'is not successful' do
        expect(result).to be_failing ['is in invalid format']
      end
    end

    context 'with invalid type' do
      let(:input) { { 'foo' => { 'a' => '1' } } }

      it 'raises error' do
        expect(result).to be_failing ['must be a string']
      end
    end

    context 'with invalid input' do
      let(:input) { { 'foo' => 'wat' } }

      it 'is not successful' do
        expect(result).to be_failing ['is in invalid format']
      end
    end
  end

  context 'with optional' do
    subject(:schema) do
      Dry::Validation.Form do
        optional(:foo) { str? & format?(/bar/) }
      end
    end

    context 'with valid input' do
      let(:input) { { 'foo' => 'bar baz' } }

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
        expect(result).to be_failing ['must be a string']
      end
    end

    context 'with blank input' do
      let(:input) { { 'foo' => '' } }

      it 'is not successful' do
        expect(result).to be_failing ['is in invalid format']
      end
    end

    context 'with invalid type' do
      let(:input) { { 'foo' => { 'a' => '1' } } }

      it 'raises error' do
        expect(result).to be_failing ['must be a string']
      end
    end

    context 'with invalid input' do
      let(:input) { { 'foo' => 'wat' } }

      it 'is not successful' do
        expect(result).to be_failing ['is in invalid format']
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).value(:str?, format?: /bar/)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => 'bar baz' } }

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
            expect(result).to be_failing ['must be a string']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['is in invalid format']
          end
        end

        context 'with invalid type' do
          let(:input) { { 'foo' => { 'a' => '1' } } }

          it 'raises error' do
            expect(result).to be_failing ['must be a string']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => 'wat' } }

          it 'is not successful' do
            expect(result).to be_failing ['is in invalid format']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).filled(:str?, format?: /bar/)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => 'bar baz' } }

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

        context 'with invalid type' do
          let(:input) { { 'foo' => { 'a' => '1' } } }

          it 'raises error' do
            expect(result).to be_failing ['must be a string']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => 'wat' } }

          it 'is not successful' do
            expect(result).to be_failing ['is in invalid format']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).maybe(:str?, format?: /bar/)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => 'bar baz' } }

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

        context 'with invalid type' do
          let(:input) { { 'foo' => { 'a' => '1' } } }

          it 'is not successful' do
            expect(result).to be_failing ['must be a string']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => 'wat' } }

          it 'is not successful' do
            expect(result).to be_failing ['is in invalid format']
          end
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).value(:str?, format?: /bar/)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => 'bar baz' } }

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
            expect(result).to be_failing ['must be a string']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['is in invalid format']
          end
        end

        context 'with invalid type' do
          let(:input) { { 'foo' => { 'a' => '1' } } }

          it 'raises error' do
            expect(result).to be_failing ['must be a string']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => 'wat' } }

          it 'is not successful' do
            expect(result).to be_failing ['is in invalid format']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).filled(:str?, format?: /bar/)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => 'bar baz' } }

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

        context 'with invalid type' do
          let(:input) { { 'foo' => { 'a' => '1' } } }

          it 'raises error' do
            expect(result).to be_failing ['must be a string']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => 'wat' } }

          it 'is not successful' do
            expect(result).to be_failing ['is in invalid format']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).maybe(:str?, format?: /bar/)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => 'bar baz' } }

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

          it 'raises error' do
            expect(result).to be_failing ['must be a string']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => 'wat' } }

          it 'is not successful' do
            expect(result).to be_failing ['is in invalid format']
          end
        end
      end
    end
  end
end
