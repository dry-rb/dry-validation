RSpec.describe 'Macros #each' do
  context 'with a block' do
    context 'with a nested key' do
      subject(:schema) do
        Dry::Validation.Schema do
          key(:songs).each do
            key(:title).required
          end
        end
      end

      it 'passes when all elements are valid' do
        songs = [{ title: 'Hello' }, { title: 'World' }]

        expect(schema.(songs: songs)).to be_success
      end

      it 'fails when value is not an array' do
        expect(schema.(songs: 'oops').messages).to eql(songs: ['must be an array'])
      end

      it 'fails when not all elements are valid' do
        songs = [{ title: 'Hello' }, { title: nil }, { title: nil }]

        expect(schema.(songs: songs).messages).to eql(
          songs: {
            1 => { title: ['must be filled'] },
            2 => { title: ['must be filled'] }
          }
        )
      end
    end

    context 'with a nested schema' do
      subject(:schema) do
        Dry::Validation.Schema do
          key(:songs).each do
            schema do
              key(:title).required
              key(:author).required
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
    subject(:schema) do
      Dry::Validation.Form do
        key(:songs).each(:str?)
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
