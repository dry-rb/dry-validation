RSpec.describe 'Check depending on nth element in an array' do
  subject(:schema) do
    Dry::Validation.Schema do
      required(:tags).each(:str?)

      rule(tags: [[:tags, 0]]) do |value|
        value.eql?('red')
      end
    end
  end

  it 'skips check when dependency failed' do
    expect(schema.(tags: 'oops')).to be_failure
  end

  it 'passes when check passes' do
    expect(schema.(tags: %w(red green blue))).to be_success
  end

  it 'fails when check fails' do
    expect(schema.(tags: %w(blue green red)).messages).to eql(
      tags: { 0 => ["must be equal to red"] }
    )
  end
end
