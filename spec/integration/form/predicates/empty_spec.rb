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
        it "raises error" do
          expect { Dry::Validation.Form do
            required(:foo).filled(:empty?)
          end }.to raise_error InvalidSchemaError
        end
      end

      context 'with maybe' do
        it "raises error" do
          expect { Dry::Validation.Form do
            required(:foo).maybe(:empty?)
          end }.to raise_error InvalidSchemaError
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
        it "raises error" do
          expect { Dry::Validation.Form do
            optional(:foo).filled(:empty?)
          end }.to raise_error InvalidSchemaError
        end
      end

      context 'with maybe' do
        it "raises error" do
          expect { Dry::Validation.Form do
            optional(:foo).maybe(:empty?)
          end }.to raise_error InvalidSchemaError
        end
      end
    end
  end
end
