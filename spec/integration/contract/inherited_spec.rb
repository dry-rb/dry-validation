require 'dry/validation/contract'

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
      params do
        required(:name).filled(:string)
      end

      rule(:name) {}
    end
  end

  it 'inherits schema params' do
    expect(child_class.schema.key_map.map(&:name).sort).to eql(["email", "name"])
  end

  it 'inherits rules' do
    expect(child_class.rules.map(&:name).sort).to eql([:email, :name])
  end
end
