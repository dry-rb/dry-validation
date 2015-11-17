RSpec.describe Dry::Validation do
  before do
    module Test
      class Validation < Dry::Validation::Schema
        key(:email).present?

        key(:age).present? do |value|
          value.int? & value.gt?(18)
        end

        key(:address).present? do |address|
          address.key(:city).present? do |city|
            city.min_size?(3)
          end
        end
      end
    end
  end

  describe 'defining schema' do
    it 'works' do
      validation = Test::Validation.new
      attrs = { email: 'jane@doe.org', age: 19, address: { city: 'NYC' } }

      expect(validation.(attrs)).to be_empty

      expect(validation.(attrs.merge(email: '', age: 18))).to match_array([
        [:error, [:rule, :email, [:result, [:input, "", [:predicate, :present?, [:email]]]]]],
        [:error, [:rule, :age, [:result, [:input, 18, [:predicate, :gt?, [18]]]]]]
      ])

      expect(validation.(name: 'Jane', age: '18', address: attrs[:address])).to match_array([
        [:error, [:rule, :email, [:result, [:input, nil, [:predicate, :present?, [:email]]]]]],
        [:error, [:rule, :age, [:result, [:input, "18", [:predicate, :int?, []]]]]]
      ])

      expect(validation.(email: 'jane@doe.org', age: 19)).to match_array([
        [:error, [:rule, :address, [:result, [:input, nil, [:predicate, :present?, [:address]]]]]]
      ])

      expect(validation.(attrs.merge(address: { city: 'NY' }))).to match_array([
        [:error, [:rule, :address, [:result, [:input, "NY", [:predicate, :min_size?, [3]]]]]]
      ])
    end
  end
end
