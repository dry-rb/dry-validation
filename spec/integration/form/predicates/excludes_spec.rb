RSpec.describe 'Predicates: Excludes' do
  context 'with required' do
    subject(:schema) do
      Dry::Validation.Form do
        required(:foo) { array? { each { int? } & excludes?(1) } }
      end
    end

    context 'with valid input' do
      let(:input) { { 'foo' => ['2', '3', '4'] } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with missing input' do
      let(:input) { {} }

      it 'is not successful' do
        expect(result).to be_failing ['is missing', 'must not include 1']
      end
    end

    context 'with nil input' do
      let(:input) { { 'foo' => nil } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an array', 'must not include 1']
      end
    end

    context 'with blank input' do
      let(:input) { { 'foo' => '' } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with invalid input' do
      let(:input) { { 'foo' => ['1', '2', '3'] } }

      it 'is not successful' do
        expect(result).to be_failing ['must not include 1']
      end
    end
  end

  context 'with optional' do
    subject(:schema) do
      Dry::Validation.Form do
        optional(:foo) { array? { each { int? } & excludes?(1) } }
      end
    end

    context 'with valid input' do
      let(:input) { { 'foo' => ['2', '3', '4'] } }

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
        expect(result).to be_failing ['must be an array', 'must not include 1']
      end
    end

    context 'with blank input' do
      let(:input) { { 'foo' => '' } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with invalid input' do
      let(:input) { { 'foo' => ['1', '2', '3'] } }

      it 'is not successful' do
        expect(result).to be_failing ['must not include 1']
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).value(excludes?: "foo")
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => "bar" } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must not include foo']
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
          let(:input) { { 'foo' => "foo" } }

          it 'is not successful' do
            expect(result).to be_failing ['must not include foo']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).filled(excludes?: 'foo')
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => "Hello World" } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must not include foo']
          end
        end

        context 'with nil input' do
          let(:input) { { 'foo' => nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must not include foo']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must not include foo']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => "foo bar" } }

          it 'is not successful' do
            expect(result).to be_failing ['must not include foo']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).maybe(excludes?: 'foo')
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => "Hello World" } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'must not include foo']
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
          let(:input) { { 'foo' => "foo bar" } }

          it 'is not successful' do
            expect(result).to be_failing ['must not include foo']
          end
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).value(excludes?: '1')
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => ['2', '3', '4'] } }

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
          let(:input) { { 'foo' => ['1', '2', '3'] } }

          it 'is not successful' do
            expect(result).to be_failing ['must not include 1']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).filled(excludes?: 'foo')
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => 'bar' } }

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
            expect(result).to be_failing ['must be filled', 'must not include foo']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'must not include foo']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => 'foo' } }

          it 'is not successful' do
            expect(result).to be_failing ['must not include foo']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).maybe(excludes?: 'foo')
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => 'bar' } }

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
          let(:input) { { 'foo' => 'foo' } }

          it 'is not successful' do
            expect(result).to be_failing ['must not include foo']
          end
        end
      end
    end
  end
end
