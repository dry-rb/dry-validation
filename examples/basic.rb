require 'dry-validation'

class Schema < Dry::Validation::Schema
  key(:email) { |email| email.filled? }

  key(:age) do |age|
    age.int? & age.gt?(18)
  end
end

schema = Schema.new

errors = schema.(email: 'goo', age: 19)

puts errors.inspect
# #<Dry::Validation::Error::Set:0x007ff3e29626d8 @errors=[]>

errors = schema.(email: nil, age: 19)

puts errors.inspect
#<Dry::Validation::Error::Set:0x007f80ac198a00 @errors=[#<Dry::Validation::Error:0x007f80ac193aa0 @result=#<Dry::Validation::Result::Value success?=false input=nil rule=#<Dry::Validation::Rule::Value name=:email predicate=#<Dry::Validation::Predicate id=:filled?>>>>]>
