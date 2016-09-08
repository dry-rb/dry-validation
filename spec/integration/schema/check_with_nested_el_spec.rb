RSpec.describe 'Check depending on a nested value from a hash' do
  subject(:schema) do
    Dry::Validation.Schema do
      required(:tag).schema do
        required(:color).schema do
          required(:value).filled(:str?)
        end
      end

      rule(tag: [[:tag, :color, :value]]) do |value|
        value.eql?('red')
      end
    end
  end

  it 'passes when check passes' do
    expect(schema.(tag: { color: { value: 'red' }})).to be_success
  end

  it 'skips check when parent of the dependency failed' do
    expect(schema.(tag: { color: :oops }).messages).to eql(
      tag: { color: ['must be a hash'] }
    )
  end

  it 'skips check when dependency failed' do
    expect(schema.(tag: { color: { value: :oops }}).messages).to eql(
      tag: { color: { value: ['must be a string'] } }
    )
  end

  it 'fails when check fails' do
    expect(schema.(tag: { color: { value: 'blue' }}).messages).to eql(
      tag: { color: { value: ['must be equal to red'] } }
    )
  end
end
