RSpec.describe 'Predicates: Size' do
  context 'Range' do
    context 'with required' do
      subject(:schema) do
        Dry::Validation.Form do
          required(:foo) { size?(2..3) }
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
          expect(result).to be_failing ['is missing', 'size must be within 2 - 3']
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

        #see: https://github.com/dry-rb/dry-validation/issues/121
        it 'is not successful' do
          expect(result).to be_failing ['length must be within 2 - 3']
        end
      end

      context 'with invalid input' do
        let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

        it 'is not successful' do
          expect(result).to be_failing ['size must be within 2 - 3']
        end
      end
    end

    context 'with optional' do
      subject(:schema) do
        Dry::Validation.Form do
          optional(:foo) { size?(2..3) }
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

        #see: https://github.com/dry-rb/dry-validation/issues/121
        it 'is not successful' do
          expect(result).to be_failing ['length must be within 2 - 3']
        end
      end

      context 'with invalid input' do
        let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

        it 'is not successful' do
          expect(result).to be_failing ['size must be within 2 - 3']
        end
      end
    end

    context 'as macro' do
      context 'with required' do
        context 'with value' do
          subject(:schema) do
            Dry::Validation.Form do
              required(:foo).value(size?: 2..3)
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
              expect(result).to be_failing ['is missing', 'size must be within 2 - 3']
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
              expect(result).to be_failing ['length must be within 2 - 3']
            end
          end

          context 'with invalid input' do
            let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

            it 'is not successful' do
              expect(result).to be_failing ['size must be within 2 - 3']
            end
          end
        end

        context 'with filled' do
          subject(:schema) do
            Dry::Validation.Form do
              required(:foo).filled(size?: 2..3)
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
              expect(result).to be_failing ['is missing', 'size must be within 2 - 3']
            end
          end

          context 'with nil input' do
            let(:input) { { 'foo' => nil } }

            it 'is not successful' do
              expect(result).to be_failing ['must be filled', 'size must be within 2 - 3']
            end
          end

          context 'with blank input' do
            let(:input) { { 'foo' => '' } }

            it 'is not successful' do
              expect(result).to be_failing ['must be filled', 'length must be within 2 - 3']
            end
          end

          context 'with invalid input' do
            let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

            it 'is not successful' do
              expect(result).to be_failing ['size must be within 2 - 3']
            end
          end
        end

        context 'with maybe' do
          subject(:schema) do
            Dry::Validation.Form do
              required(:foo).maybe(size?: 2..3)
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
              expect(result).to be_failing ['is missing', 'size must be within 2 - 3']
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

            it 'is not successful' do
              expect(result).to be_failing ['size must be within 2 - 3']
            end
          end
        end
      end

      context 'with optional' do
        context 'with value' do
          subject(:schema) do
            Dry::Validation.Form do
              optional(:foo).value(size?: 2..3)
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

            #see: https://github.com/dry-rb/dry-validation/issues/121
            it 'is not successful' do
              expect(result).to be_failing ['length must be within 2 - 3']
            end
          end

          context 'with invalid input' do
            let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

            it 'is not successful' do
              expect(result).to be_failing ['size must be within 2 - 3']
            end
          end
        end

        context 'with filled' do
          subject(:schema) do
            Dry::Validation.Form do
              optional(:foo).filled(size?: 2..3)
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
              expect(result).to be_failing ['must be filled', 'size must be within 2 - 3']
            end
          end

          context 'with blank input' do
            let(:input) { { 'foo' => '' } }

            it 'is not successful' do
              expect(result).to be_failing ['must be filled', 'length must be within 2 - 3']
            end
          end

          context 'with invalid input' do
            let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

            it 'is not successful' do
              expect(result).to be_failing ['size must be within 2 - 3']
            end
          end
        end

        context 'with maybe' do
          subject(:schema) do
            Dry::Validation.Form do
              optional(:foo).maybe(size?: 2..3)
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
            let(:input) { { 'foo' => { 'a' => '1', 'b' => '2', 'c' => '3', 'd' => '4' } } }

            it 'is not successful' do
              expect(result).to be_failing ['size must be within 2 - 3']
            end
          end
        end
      end
    end
  end
end
