RSpec.describe 'Macros #each' do
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
