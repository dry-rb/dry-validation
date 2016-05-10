RSpec.describe 'Predicates: Max Size' do
  context 'with required' do
    subject(:schema) do
      Dry::Validation.Form do
        required(:foo) { max_size?(3) }
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
        expect(result).to be_failing ['is missing', 'size cannot be greater than 3']
      end
    end

    context 'with nil input' do
      let(:input) { { 'foo' => nil } }

      it 'is raises error' do
        expect { result }.to raise_error(NoMethodError)
      end
    end

    context 'with blank input' do
      let(:input) { { 'foo' => '' } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with invalid input' do
      let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

      it 'is not successful' do
        expect(result).to be_failing ['size cannot be greater than 3']
      end
    end
  end

  context 'with optional' do
    subject(:schema) do
      Dry::Validation.Form do
        optional(:foo) { max_size?(3) }
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

      it 'is raises error' do
        expect { result }.to raise_error(NoMethodError)
      end
    end

    context 'with blank input' do
      let(:input) { { 'foo' => '' } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with invalid input' do
      let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

      it 'is not successful' do
        expect(result).to be_failing ['size cannot be greater than 3']
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).value(max_size?: 3)
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
            expect(result).to be_failing ['is missing', 'size cannot be greater than 3']
          end
        end

        context 'with nil input' do
          let(:input) { { 'foo' => nil } }

          it 'is not successful' do
            expect { result }.to raise_error(NoMethodError)
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

          it 'is not successful' do
            expect(result).to be_failing ['size cannot be greater than 3']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).filled(max_size?: 3)
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
            expect(result).to be_failing ['is missing', 'size cannot be greater than 3']
          end
        end

        context 'with nil input' do
          let(:input) { { 'foo' => nil } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'size cannot be greater than 3']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'size cannot be greater than 3']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

          it 'is not successful' do
            expect(result).to be_failing ['size cannot be greater than 3']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Form do
            required(:foo).maybe(max_size?: 3)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => %w(1 2 3) } }

          # See: https://github.com/dry-rb/dry-validation/issues/133
          xit 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with missing input' do
          let(:input) { {} }

          it 'is not successful' do
            expect(result).to be_failing ['is missing', 'size cannot be greater than 3']
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
          let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

          # See https://github.com/dry-rb/dry-validation/issues/133#issuecomment-216556509
          xit 'is not successful' do
            expect(result).to be_failing ['size cannot be greater than 3']
          end
        end
      end
    end

    context 'with optional' do
      context 'with value' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).value(max_size?: 3)
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

          it 'is raises error' do
            expect { result }.to raise_error(NoMethodError)
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is successful' do
            expect(result).to be_successful
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

          it 'is not successful' do
            expect(result).to be_failing ['size cannot be greater than 3']
          end
        end
      end

      context 'with filled' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).filled(max_size?: 3)
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
            expect(result).to be_failing ['must be filled', 'size cannot be greater than 3']
          end
        end

        context 'with blank input' do
          let(:input) { { 'foo' => '' } }

          it 'is not successful' do
            expect(result).to be_failing ['must be filled', 'size cannot be greater than 3']
          end
        end

        context 'with invalid input' do
          let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

          it 'is not successful' do
            expect(result).to be_failing ['size cannot be greater than 3']
          end
        end
      end

      context 'with maybe' do
        subject(:schema) do
          Dry::Validation.Form do
            optional(:foo).maybe(max_size?: 3)
          end
        end

        context 'with valid input' do
          let(:input) { { 'foo' => %w([1 2 3) } }

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
          let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

          # See: https://github.com/dry-rb/dry-validation/issues/133#issuecomment-216555937
          it 'is not successful'
          # it 'is not successful' do
          #   expect(result).to be_failing ['size cannot be greater than 3']
          # end
        end
      end
    end
  end
end
