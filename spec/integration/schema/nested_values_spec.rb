RSpec.describe Schema, 'using nested values' do
  let(:schema) do
    Dry::Validation.Schema do
      required(:email).maybe

      required(:settings).schema do
        optional(:offers).filled(:bool?)
        required(:newsletter).filled(:bool?)
      end

      rule(newsletter: [[:settings, :newsletter], [:settings, :offers]]) do |newsletter, offers|
        offers.true?.then(newsletter.false?)
      end

      rule(email: [[:settings, :newsletter], :email]) do |newsletter, email|
        newsletter.true?.then(email.filled?)
      end
    end
  end

  it 'passes when newsletter setting is false' do
    expect(schema.(settings: { newsletter: false }, email: nil)).to be_success
  end

  it 'passes when newsletter setting is true and email is filled' do
    expect(schema.(settings: { newsletter: false }, email: 'jane@doe')).to be_success
  end

  it 'passes when offers is false and newsletter is true' do
    expect(schema.(settings: { offers: false, newsletter: true }, email: 'jane@doe')).to be_success
  end

  it 'fails when newsletter is true and email is not filled' do
    expect(schema.(settings: { newsletter: true }, email: nil).messages).to eql(
      email: ['must be filled']
    )
  end

  it 'fails when offers is true and newsletter is true' do
    input = { settings: { offers: true, newsletter: true }, email: 'jane@doe' }

    expect(schema.(input).messages).to eql(
      settings: { newsletter: ['must be false'] }
    )
  end
end
