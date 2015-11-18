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

          address.key(:country) do |country|
            country.key(:name, &:filled?)
            country.key(:code, &:filled?)
          end
        end

        key(:phone_numbers) do |phone_numbers|
          phone_numbers.each(&:str?)
        end
      end
    end
  end

  describe 'defining schema' do
    it 'works' do
      validation = Test::Validation.new
      attrs = {
        email: 'jane@doe.org',
        age: 19,
        address: { city: 'NYC', street: 'Street 1/2', country: { code: 'US', name: 'USA' } },
        phone_numbers: [
          '123456', '234567'
        ]
      }

      expect(validation.(attrs)).to be_empty

      expect(validation.(attrs.merge(email: '', age: 18))).to match_array([
        [:error, [:input, "", [:rule, [:email, [:filled?, []]]]]],
        [:error, [:input, 18, [:rule, [:age, [:gt?, [18]]]]]]
      ])

      expect(validation.(name: 'Jane', age: '18', address: attrs[:address], phone_numbers: attrs[:phone_numbers])).to match_array([
        [:error, [:input, nil, [:rule, [:email, [:key?, [:email]]]]]],
        [:error, [:input, "18", [:rule, [:age, [:int?, []]]]]]
      ])

      expect(validation.(email: 'jane@doe.org', age: 19)).to match_array([
        [:error, [:input, nil, [:rule, [:address, [:key?, [:address]]]]]],
        [:error, [:input, nil, [:rule, [:phone_numbers, [:key?, [:phone_numbers]]]]]]
      ])

      expect(validation.(attrs.merge(address: { city: 'NY' }))).to match_array([
        [:error, [
          :set, [
            [:input, "NY", [:rule, [:city, [:min_size?, [3]]]]],
            [:input, nil, [:rule, [:street, [:key?, [:street]]]]],
            [:input, nil, [:rule, [:country, [:key?, [:country]]]]]
          ]
        ]]
      ])

      expect(validation.(attrs.merge(address: attrs[:address].merge(country: { code: 'US', name: '' })))).to match_array([
        [:error, [:set, [[:set, [[:input, "", [:rule, [:name, [:filled?, []]]]]]]]]]
      ])
    end
  end
end
