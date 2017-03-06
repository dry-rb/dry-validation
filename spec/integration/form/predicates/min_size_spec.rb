RSpec.describe 'Predicates: Min Size' do
  context 'with required' do
    subject(:schema) do
      Dry::Validation.Form do
        required(:foo) { min_size?(3) }
      end
    end

    context 'with valid input' do
      let(:input) { { 'foo' => %w(1 2 3) } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with missing input' do
      let(:input) { {} }

      it 'is not successful' do
        expect(result).to be_failing ['is missing', 'size cannot be less than 3']
      end
    end

    context 'with nil input' do
      let(:input) { { 'foo' => nil } }

      it 'raises error' do
        expect { result }.to raise_error(NoMethodError)
      end
    end

    context 'with blank input' do
      let(:input) { { 'foo' => '' } }

      it 'is not successful' do
        expect(result).to be_failing ['size cannot be less than 3']
      end
    end

    context 'with invalid input' do
      let(:input) { { 'foo' => { 'a' => '1', 'b' => '2' } } }

      it 'is not successful' do
        expect(result).to be_failing ['size cannot be less than 3']
      end
    end
  end

  context 'with optional' do
    subject(:schema) do
      Dry::Validation.Form do
        optional(:foo) { min_size?(3) }
      end
    end

    context 'with valid input' do
      let(:input) { { 'foo' => %w(1 2 3) } }

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

      it 'raises error' do
        expect { result }.to raise_error(NoMethodError)
      end
    end

    context 'with blank input' do
      let(:input) { { 'foo' => '' } }

      it 'is not successful' do
        expect(result).to be_failing ['size cannot be less than 3']
      end
    end

    context 'with invalid input' do
      let(:input) { { 'foo' => { 'a' => '1', 'b' => '2' } } }

      it 'is not successful' do
        expect(result).to be_failing ['size cannot be less than 3']
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).value(min_size?: 3)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => %w(1 2 3) } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'size cannot be less than 3']
          end
        end

        context 'with nil input' do
          let(:input) { { 'foo' => nil } }

          it 'raises error' do
            expect { result }.to raise_error(NoMethodError)
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['size cannot be less than 3']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => { 'a' => '1', 'b' => '2' } } }

          it 'is not successful' do
            expect(result).to be_failing ['size cannot be less than 3']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).filled(min_size?: 3)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => %w(1 2 3) } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'size cannot be less than 3']
          end
        end

        context 'with nil input' do
          let(:input) { { 'foo' => nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'size cannot be less than 3']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'size cannot be less than 3']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => { 'a' => '1', 'b' => '2' } } }

          it 'is not successful' do
            expect(result).to be_failing ['size cannot be less than 3']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).maybe(min_size?: 3)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => %w(1 2 3) } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'size cannot be less than 3']
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
          let(:input) { { 'foo' => { 'a' => '1', 'b' => '2' } } }

          it 'is not successful' do
            expect(result).to be_failing ['size cannot be less than 3']
          end
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).value(min_size?: 3)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => %w(1 2 3) } }

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

          it 'raises error' do
            expect { result }.to raise_error(NoMethodError)
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['size cannot be less than 3']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => { 'a' => '1', 'b' => '2' } } }

          it 'is not successful' do
            expect(result).to be_failing ['size cannot be less than 3']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).filled(min_size?: 3)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => %w(1 2 3) } }

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
            expect(result).to be_failing ['must be filled', 'size cannot be less than 3']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'size cannot be less than 3']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => { 'a' => '1', 'b' => '2' } } }

          it 'is not successful' do
            expect(result).to be_failing ['size cannot be less than 3']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).maybe(min_size?: 3)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => %w(1 2 3) } }

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
          let(:input) { { 'foo' => { 'a' => '1', 'b' => '2' } } }

          it 'is not successful' do
            expect(result).to be_failing ['size cannot be less than 3']
          end
        end
      end
    end
  end
end
