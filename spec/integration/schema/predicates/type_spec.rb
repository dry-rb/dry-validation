RSpec.describe 'Predicates: Type' do
  context 'with required' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:foo) { type?(Integer) }
      end
    end

    context 'with valid input' do
      let(:input) { { foo: 23 } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with missing input' do
      let(:input) { {} }

      it 'is not successful' do
        expect(result).to be_failing ['is missing', 'must be Integer']
      end
    end

    context 'with nil input' do
      let(:input) { { foo: nil } }

      it 'is not successful' do
        expect(result).to be_failing ['must be Integer']
      end
    end

    context 'with blank input' do
      let(:input) { { foo: '' } }

      it 'is not successful' do
        expect(result).to be_failing ['must be Integer']
      end
    end

    context 'with invalid type' do
      let(:input) { { foo: [:x] } }

      it 'is not successful' do
        expect(result).to be_failing ['must be Integer']
      end
    end
  end

  context 'with optional' do
    subject(:schema) do
      Dry::Validation.Schema do
        optional(:foo) { type?(Integer) }
      end
    end

    context 'with valid input' do
      let(:input) { { foo: 23 } }

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
        expect(result).to be_failing ['must be Integer']
      end
    end

    context 'with blank input' do
      let(:input) { { foo: '' } }

      it 'is not successful' do
        expect(result).to be_failing ['must be Integer']
      end
    end

    context 'with invalid type' do
      let(:input) { { foo: [:x] } }

      it 'is not successful' do
        expect(result).to be_failing ['must be Integer']
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Schema do
            required(:foo).value(type?: Integer)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: 23 } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must be Integer']
          end
        end

        context 'with nil input' do
          let(:input) { { foo: nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be Integer']
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be Integer']
          end
        end

        context 'with invalid type' do
          let(:input) { { foo: [:x] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be Integer']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Schema do
            required(:foo).filled(type?: Integer)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: 23 } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must be Integer']
          end
        end

        context 'with nil input' do
          let(:input) { { foo: nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must be Integer']
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must be Integer']
          end
        end

        context 'with invalid type' do
          let(:input) { { foo: [:x] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be Integer']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Schema do
            required(:foo).maybe(type?: Integer)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: 23 } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must be Integer']
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
            expect(result).to be_failing ['must be Integer']
          end
        end

        context 'with invalid type' do
          let(:input) { { foo: [:x] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be Integer']
          end
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Schema do
            optional(:foo).value(type?: Integer)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: 23 } }

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
            expect(result).to be_failing ['must be Integer']
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be Integer']
          end
        end

        context 'with invalid type' do
          let(:input) { { foo: [:x] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be Integer']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Schema do
            optional(:foo).filled(type?: Integer)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: 23 } }

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
            expect(result).to be_failing ['must be filled', 'must be Integer']
          end
        end

        context 'with blank input' do
          let(:input) { { foo: '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must be Integer']
          end
        end

        context 'with invalid type' do
          let(:input) { { foo: [:x] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be Integer']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Schema do
            optional(:foo).maybe(type?: Integer)
          end
        end

        context 'with valid input' do
          let(:input) { { foo: 23 } }

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
            expect(result).to be_failing ['must be Integer']
          end
        end

        context 'with invalid type' do
          let(:input) { { foo: [:x] } }

          it 'is not successful' do
            expect(result).to be_failing ['must be Integer']
          end
        end
      end
    end
  end

  context 'with a custom class' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:foo).value(type?: CustomClass)
      end
    end

    around do |example|
      CustomClass = Class.new
      example.run
      Object.send(:remove_const, :CustomClass)
    end

    it 'succeeds with valid input' do
      expect(schema.(foo: CustomClass.new)).to be_success
    end

    it 'fails with invalid input' do
      expect(schema.(foo: 'oops')).to be_failing ["must be #{CustomClass}"]
    end
  end
end
