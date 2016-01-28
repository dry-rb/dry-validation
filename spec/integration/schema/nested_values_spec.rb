RSpec.describe Schema, 'using nested values' do
  subject(:validate) { schema.new }

  let(:schema) do
    Class.new(Schema) do
      key(:email).maybe

      key(:settings) do |settings|
        settings.optional(:offers).maybe(:bool?).when(:true?) do
          settings.value(:newsletter).false?
        end

        settings.key(:newsletter).required(:bool?).when(:true?) do
          value(:email).filled?
        end
      end
    end
  end

  it 'passes when newsletter setting is false' do
    expect(validate.(settings: { newsletter: false }, email: nil)).to be_empty
  end

  it 'passes when newsletter setting is true and email is filled' do
    expect(validate.(settings: { newsletter: false }, email: 'jane@doe')).to be_empty
  end

  it 'passes when offers is false and newsletter is true' do
    expect(validate.(settings: { offers: false, newsletter: true }, email: 'jane@doe')).to be_empty
  end

  it 'fails when newsletter is true and email is not filled' do
    expect(validate.(settings: { newsletter: true }, email: nil).messages).to eql(
      email: [['email must be filled'], [true, nil]]
    )
  end

  it 'fails when offers is true and newsletter is true' do
    expect(validate.(settings: { offers: true, newsletter: true }, email: 'jane@doe').messages).to eql(
      settings: [['newsletter must be false'], [true, true]]
    )
  end
end
