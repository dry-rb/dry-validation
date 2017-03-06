RSpec.describe 'Predicates: None' do
  context 'with required' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:foo) { none? }
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

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with blank input' do
      let(:input) { { foo: '' } }

      it 'is not successful' do
        expect(result).to be_failing ['cannot be defined']
      end
    end

    context 'with other input' do
      let(:input) { { foo: 23 } }

      it 'is not successful' do
        expect(result).to be_failing ['cannot be defined']
      end
    end
  end

  context 'with optional' do
    subject(:schema) do
      Dry::Validation.Schema do
        optional(:foo) { none? }
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
        expect(result).to be_failing ['cannot be defined']
      end
    end

    context 'with other input' do
      let(:input) { { foo: 23 } }

      it 'is not successful' do
        expect(result).to be_failing ['cannot be defined']
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Schema do
            required(:foo).value(:none?)
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

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['cannot be defined']
          end
        end

        context 'with other input' do
          let(:input) { { foo: 23 } }

          it 'is not successful' do
            expect(result).to be_failing ['cannot be defined']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Schema do
            required(:foo).filled(:none?)
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
            expect(result).to be_failing ['must be filled']
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled']
          end
        end

        context 'with other input' do
          let(:input) { { foo: 23 } }

          it 'is not successful' do
            expect(result).to be_failing ['cannot be defined']
          end
        end
      end

      #makes no sense see: #134
      context 'with maybe' do
        it "raises error" do
          expect { Dry::Validation.Schema do
            required(:foo).maybe(:none?)
          end }.to raise_error InvalidSchemaError
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Schema do
            optional(:foo).value(:none?)
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
            expect(result).to be_failing ['cannot be defined']
          end
        end

        context 'with other input' do
          let(:input) { { foo: 23 } }

          it 'is not successful' do
            expect(result).to be_failing ['cannot be defined']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Schema do
            optional(:foo).filled(:none?)
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
            expect(result).to be_failing ['must be filled']
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled']
          end
        end

        context 'with other input' do
          let(:input) { { foo: 23 } }

          it 'is not successful' do
            expect(result).to be_failing ['cannot be defined']
          end
        end
      end

      #makes no sense see: #134
      context 'with maybe' do
        it "raises error" do
          expect { Dry::Validation.Schema do
            optional(:foo).maybe(:none?)
          end }.to raise_error InvalidSchemaError
        end
      end
    end
  end
end
