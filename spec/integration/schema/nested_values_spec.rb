RSpec.describe Schema, 'using nested values' do
  let(:schema) do
    Dry::Validation.Schema do
      key(:email).maybe

      key(:settings) do
        optional(:offers).required(:bool?).when(:true?) do
          value([:settings, :newsletter]).false?
        end

        key(:newsletter).required(:bool?).when(:true?) do
          value(:email).filled?
        end
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
    expect(schema.(settings: { offers: true, newsletter: true }, email: 'jane@doe').messages).to eql(
      settings: { newsletter: ['must be false'] }
    )
  end
end
