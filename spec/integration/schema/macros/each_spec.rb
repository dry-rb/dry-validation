RSpec.describe 'Macros #each' do
  context "predicate without options" do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:foo).each(:filled?, :str?)
      end
    end

    context 'with valid input' do
      let(:input) { { foo: %w(a b c) } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with invalid input' do
      let(:input) { { foo: [[1, 2], "", "foo"] } }

      it 'is not successful' do
        expect(result).to be_failing(0 => ["must be a string"], 1 => ["must be filled"])
      end
    end

    context 'with invalid input type' do
      let(:input) { { foo: nil } }

      it 'is not successful' do
        expect(result).to be_failing ["must be an array"]
      end
    end
  end

  context "predicate with options" do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:foo).each(size?: 3)
      end
    end

    context 'with valid input' do
      let(:input) { { foo: [[1,2,3], "foo"] } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with invalid input' do
      let(:input) { { foo: [[1,2], "foo"] } }

      it 'is not successful' do
        expect(result).to be_failing({0=>["size must be 3"]})
      end
    end

    context 'with invalid input type' do
      let(:input) { { foo: nil } }

      it 'is not successful' do
        expect(result).to be_failing ["must be an array", "size must be 3"]
      end
    end
  end

  context 'with filled macro' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:foo).filled(size?: 2) { each(:str?) }
      end
    end

    context 'with valid input' do
      let(:input) { { foo: %w(a b) } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'when value is not valid' do
      let(:input) { { foo: ["foo"] } }

      it 'is not successful' do
        expect(result).to be_failing(["size must be 2"])
      end
    end

    context 'when value has invalid elements' do
      let(:input) { { foo: [:foo, "foo"] } }

      it 'is not successful' do
        expect(result).to be_failing(0 => ["must be a string"])
      end
    end
  end

  context 'with maybe macro' do
    subject(:schema) do
      Dry::Validation.Schema do
        required(:foo).maybe { each(:str?) }
      end
    end

    context 'with nil input' do
      let(:input) { { foo: nil } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with valid input' do
      let(:input) { { foo: %w(a b c) } }

      it 'is successful' do
        expect(result).to be_successful
      end
    end

    context 'with invalid input' do
      let(:input) { { foo: [:foo, "foo"] } }

      it 'is not successful' do
        expect(result).to be_failing(0 => ["must be a string"])
      end
    end
  end

  context 'with a block' do
    context 'with a nested schema' do
      subject(:schema) do
        Dry::Validation.Schema do
          required(:songs).each do
            schema do
              required(:title).filled
              required(:author).filled
            end
          end
        end
      end

      it 'passes when all elements are valid' do
        songs = [
          { title: 'Hello', author: 'Jane' },
          { title: 'World', author: 'Joe' }
        ]

        expect(schema.(songs: songs)).to be_success
      end

      it 'fails when value is not an array' do
        expect(schema.(songs: 'oops').messages).to eql(songs: ['must be an array'])
      end

      it 'fails when not all elements are valid' do
        songs = [
          { title: 'Hello', author: 'Jane' },
          { title: nil, author: 'Joe' },
          { title: 'World', author: nil },
          { title: nil, author: nil }
        ]

        expect(schema.(songs: songs).messages).to eql(
          songs: {
            1 => { title: ['must be filled'] },
            2 => { author: ['must be filled'] },
            3 => { title: ['must be filled'], author: ['must be filled'] }
          }
        )
      end
    end
  end

  context 'with inferred predicates and a form schema' do
    context "predicate w/o options" do
      subject(:schema) do
        Dry::Validation.Form do
          required(:songs).each(:str?)
        end
      end

      it 'passes when all elements are valid' do
        songs = %w(hello world)

        expect(schema.(songs: songs)).to be_success
      end

      it 'fails when value is not an array' do
        expect(schema.(songs: 'oops').messages).to eql(songs: ['must be an array'])
      end

      it 'fails when not all elements are valid' do
        songs = ['hello', nil, 2]

        expect(schema.(songs: songs).messages).to eql(
          songs: {
            1 => ['must be a string'],
            2 => ['must be a string']
          }
        )
      end
    end
  end
end
