RSpec.describe 'Predicates: Array' do
  context 'with required' do
    subject(:schema) do
      Dry::Validation.Form do
        required(:foo) { array? { each { int? } } }
      end
    end

    context 'with valid input' do
      let(:input) { { 'foo' => ['3'] } }

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
        expect(result).to be_failing ['must be an array']
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

      it 'is not successful' do
        expect(result).to be_failing ['must be an array']
      end
    end

    context 'with invalid input (integer)' do
      let(:input) { { 'foo' => '4' } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an array']
      end
    end

    context 'with invalid input (array with non-integers)' do
      let(:input) { { 'foo' => %w(foo bar) } }

      it 'is not successful' do
        expect(result).to be_failing 0 => ['must be an integer'], 1 => ['must be an integer']
      end
    end

    context 'with invalid input (mixed array)' do
      let(:input) { { 'foo' => %w(1 bar) } }

      it 'is not successful' do
        expect(result).to be_failing 1 => ['must be an integer']
      end
    end
  end

  context 'with optional' do
    subject(:schema) do
      Dry::Validation.Form do
        optional(:foo) { array? { each { int? } } }
      end
    end

    context 'with valid input' do
      let(:input) { { 'foo' => ['3'] } }

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
        expect(result).to be_failing ['must be an array']
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

      it 'is not successful' do
        expect(result).to be_failing ['must be an array']
      end
    end

    context 'with invalid input (integer)' do
      let(:input) { { 'foo' => '4' } }

      it 'is not successful' do
        expect(result).to be_failing ['must be an array']
      end
    end

    context 'with invalid input (array with non-integers)' do
      let(:input) { { 'foo' => %w(foo bar) } }

      it 'is not successful' do
        expect(result).to be_failing 0 => ['must be an integer'], 1 => ['must be an integer']
      end
    end

    context 'with invalid input (mixed array)' do
      let(:input) { { 'foo' => %w(1 bar) } }

      it 'is not successful' do
        expect(result).to be_failing 1 => ['must be an integer']
      end
    end
  end

  context 'as macro' do
    context 'with required' do
      subject(:schema) do
        Dry::Validation.Form do
          required(:foo).each(:int?)
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
          expect(result).to be_failing ['must be an array']
        end
      end

      context 'with blank input' do
        let(:input) { { 'foo' => '' } }

        it 'is successful' do
          expect(result).to be_successful
        end
      end

      context 'with valid input' do
        let(:input) { { 'foo' => ['3'] } }

        it 'is successful' do
          expect(result).to be_successful
        end
      end

      context 'with invalid input' do
        let(:input) { { 'foo' => ['bar'] } }

        it 'is not successful' do
          expect(result).to be_failing 0 => ['must be an integer']
        end
      end
    end

    context 'with optional' do
      subject(:schema) do
        Dry::Validation.Form do
          optional(:foo).each(:int?)
        end
      end

      context 'with missing input' do
        let(:input) { {} }

        it 'is not successful' do
          expect(result).to be_successful
        end
      end

      context 'with nil input' do
        let(:input) { { 'foo' => nil } }

        it 'is not successful' do
          expect(result).to be_failing ['must be an array']
        end
      end

      context 'with blank input' do
        let(:input) { { 'foo' => '' } }

        it 'is successful' do
          expect(result).to be_successful
        end
      end

      context 'with valid input' do
        let(:input) { { 'foo' => ['3'] } }

        it 'is successful' do
          expect(result).to be_successful
        end
      end

      context 'with invalid input' do
        let(:input) { { 'foo' => ['bar'] } }

        it 'is not successful' do
          expect(result).to be_failing 0 => ['must be an integer']
        end
      end
    end
  end

  context 'with maybe macro' do
    subject(:schema) { Dry::Validation.Form { required(:foo).maybe(:array?) } }

    context 'with empty string' do
      let(:input) { { 'foo' => '' } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with nil' do
      let(:input) { { 'foo' => nil } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with empty array' do
      let(:input) { { 'foo' => [] } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with filled array' do
      let(:input) { { 'foo' => [1, 2, 3] } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with invalid value' do
      let(:input) { { 'foo' => 'oops' } }

      it 'is not successful' do
        expect(result).to be_failing(['must be an array'])
      end
    end
  end
end
