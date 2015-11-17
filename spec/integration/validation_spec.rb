RSpec.describe Dry::Validation do
  before do
    module Test
      class Validation < Dry::Validation::Schema
        key?(:email) { |value| value.filled? }

        key?(:age) do |value|
          value.int? & value.gt?(18)
        end

        key?(:address) do |address|
          address.key?(:city) do |city|
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
        [:error, [:rule, :email, [:result, [:input, "", [:predicate, :filled?, []]]]]],
        [:error, [:rule, :age, [:result, [:input, 18, [:predicate, :gt?, [18]]]]]]
      ])

      expect(validation.(name: 'Jane', age: '18', address: attrs[:address])).to match_array([
        [:error, [:rule, :email, [:result, [:input, nil, [:predicate, :key?, [:email]]]]]],
        [:error, [:rule, :age, [:result, [:input, "18", [:predicate, :int?, []]]]]]
      ])

      expect(validation.(email: 'jane@doe.org', age: 19)).to match_array([
        [:error, [:rule, :address, [:result, [:input, nil, [:predicate, :key?, [:address]]]]]]
      ])

      expect(validation.(attrs.merge(address: { city: 'NY' }))).to match_array([
        [:error, [:rule, :address, [:result, [:input, "NY", [:predicate, :min_size?, [3]]]]]]
      ])
    end
  end
end
