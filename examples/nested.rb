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

errors = schema.messages({})

puts errors.inspect
#<Dry::Validation::Error::Set:0x007fc4f89c4360 @errors=[#<Dry::Validation::Error:0x007fc4f89c4108 @result=#<Dry::Validation::Result::Value success?=false input=nil rule=#<Dry::Validation::Rule::Key name=:address predicate=#<Dry::Validation::Predicate id=:key?>>>>]>

errors = schema.messages(address: { city: 'NYC' })

puts errors.inspect
#<Dry::Validation::Error::Set:0x007fd151189b18 @errors=[#<Dry::Validation::Error:0x007fd151188e20 @result=#<Dry::Validation::Result::Set success?=false input={:city=>"NYC"} rule=#<Dry::Validation::Rule::Set name=:address predicate=[#<Dry::Validation::Rule::Conjunction left=#<Dry::Validation::Rule::Key name=:city predicate=#<Dry::Validation::Predicate id=:key?>> right=#<Dry::Validation::Rule::Value name=:city predicate=#<Dry::Validation::Predicate id=:min_size?>>>, #<Dry::Validation::Rule::Conjunction left=#<Dry::Validation::Rule::Key name=:street predicate=#<Dry::Validation::Predicate id=:key?>> right=#<Dry::Validation::Rule::Value name=:street predicate=#<Dry::Validation::Predicate id=:filled?>>>, #<Dry::Validation::Rule::Conjunction left=#<Dry::Validation::Rule::Key name=:country predicate=#<Dry::Validation::Predicate id=:key?>> right=#<Dry::Validation::Rule::Set name=:country predicate=[#<Dry::Validation::Rule::Conjunction left=#<Dry::Validation::Rule::Key name=:name predicate=#<Dry::Validation::Predicate id=:key?>> right=#<Dry::Validation::Rule::Value name=:name predicate=#<Dry::Validation::Predicate id=:filled?>>>, #<Dry::Validation::Rule::Conjunction left=#<Dry::Validation::Rule::Key name=:code predicate=#<Dry::Validation::Predicate id=:key?>> right=#<Dry::Validation::Rule::Value name=:code predicate=#<Dry::Validation::Predicate id=:filled?>>>]>>]>>>]>
