RSpec.describe Dry::Validation do
  before do
    module Test
      class Validation < Dry::Validation::Schema
        key(:email) { |email| email.filled? }

        key(:age) do |age|
          age.int? & age.gt?(18)
        end

        key(:address) do |address|
          address.key(:city) do |city|
            city.min_size?(3)
          end

          address.key(:street) do |street|
            street.filled?
          end
        end
      end
    end
  end

  describe 'defining schema' do
    it 'works' do
      validation = Test::Validation.new
      attrs = { email: 'jane@doe.org', age: 19, address: { city: 'NYC', street: 'Street 1/2' } }

      expect(validation.(attrs)).to be_empty

      expect(validation.(attrs.merge(email: '', age: 18))).to match_array([
        [:error, [:input, "", [:rule, [:email, [:filled?, []]]]]],
        [:error, [:input, 18, [:rule, [:age, [:gt?, [18]]]]]]
      ])

      expect(validation.(name: 'Jane', age: '18', address: attrs[:address])).to match_array([
        [:error, [:input, nil, [:rule, [:email, [:key?, [:email]]]]]],
        [:error, [:input, "18", [:rule, [:age, [:int?, []]]]]]
      ])

      expect(validation.(email: 'jane@doe.org', age: 19)).to match_array([
        [:error, [:input, nil, [:rule, [:address, [:key?, [:address]]]]]]
      ])

      expect(validation.(attrs.merge(address: { city: 'NY' }))).to match_array([
        [:error, [
          :set, [
            [:input, "NY", [:rule, [:city, [:min_size?, [3]]]]],
            [:input, nil, [:rule, [:street, [:key?, [:street]]]]]
          ]
        ]]
      ])
    end
  end
end
