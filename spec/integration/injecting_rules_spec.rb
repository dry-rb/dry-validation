RSpec.describe 'Schema / Injecting Rules' do
  subject(:schema) do
    Dry::Validation.Schema(rules: other.class.rules) do
      required(:email).maybe

      rule(:email) { value(:login).true? > value(:email).filled? }
    end
  end

  let(:other) do
    Dry::Validation.Schema do
      required(:login) { |value| value.bool? }
    end
  end

  it 'appends rules from another schema' do
    expect(schema.(login: true, email: 'jane@doe')).to be_success
    expect(schema.(login: false, email: nil)).to be_success
    expect(schema.(login: true, email: nil)).to_not be_success
    expect(schema.(login: nil, email: 'jane@doe')).to_not be_success
  end

  it 'keeps the original schema rules intact' do
    expect(other.class.rules.size).to eq(1)

    schema.(login: true, email: 'jane@doe')

    expect(other.class.rules.size).to eq(1)
  end
end
