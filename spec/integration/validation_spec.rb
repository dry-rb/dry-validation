RSpec.describe Dry::Validation do
  before do
    module Test
      class Validation < Dry::Validation::Schema
        key(:email).present?

        key(:age).present? do |value|
          value.int? & value.gt?(18)
        end
      end
    end
  end

  describe 'defining schema' do
    it 'works' do
      validation = Test::Validation.new

      expect(validation.(email: 'jane@doe.org', age: 19)).to be_empty

      expect(validation.(email: '', age: 18)).to match_array([
        [:error, [:rule, :email, [:result, [:input, "", [:predicate, :present?]]]]],
        [:error, [:rule, :age, [:result, [:input, 18, [:predicate, :gt?]]]]]
      ])

      expect(validation.(name: 'Jane', age: '18')).to match_array([
        [:error, [:rule, :age, [:result, [:input, "18", [:predicate, :int?]]]]],
        [:error, [:rule, :email, [:result, [:input, nil, [:predicate, :present?]]]]]
      ])
    end
  end
end
