RSpec.describe Dry::Validation::Schema, 'default settings' do
  subject(:schema) do
    Dry::Validation.Schema(build: false) do
      required(:name).filled
    end
  end

  it 'uses :yaml messages by default' do
    expect(schema.config.messages).to be(:yaml)
  end
end
