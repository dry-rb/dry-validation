# frozen_string_literal: true

require 'dry/validation/contract'
require 'dry/schema/messages/i18n'

RSpec.describe Dry::Validation::Contract, '.inherited' do
  subject(:child_class) do
    Class.new(parent_class) do
      params do
        required(:email).filled(:string)
      end

      rule(:email) {}
    end
  end

  let(:parent_class) do
    Class.new(Dry::Validation::Contract) do
      config.messages = :i18n

      params do
        required(:name).filled(:string)
      end

      rule(:name) {}
    end
  end

  it 'inherits schema params' do
    expect(child_class.__schema__.key_map.map(&:name).sort).to eql(%w[email name])
  end

  it 'inherits rules' do
    expect(child_class.rules.map(&:keys).sort).to eql([[:email], [:name]])
  end

  it 'inherits configuration' do
    expect(child_class.config.messages).to eql(parent_class.config.messages)
  end
end
