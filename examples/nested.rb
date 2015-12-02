require 'dry-validation'

class Schema < Dry::Validation::Schema
  key(:address) do |address|
    address.hash? do
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
  end
end

schema = Schema.new

errors = schema.call({}).messages

puts errors.inspect

errors = schema.call(address: { city: 'NYC' }).messages

puts errors.inspect
