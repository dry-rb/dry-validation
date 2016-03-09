require 'dry-validation'

schema = Dry::Validation.Schema do
  key(:address).schema do
    key(:city).required(min_size?: 3)

    key(:street).required

    key(:country).schema do
      key(:name).required
      key(:code).required
    end
  end
end

errors = schema.call({}).messages

puts errors.inspect

errors = schema.call(address: { city: 'NYC' }).messages

puts errors.inspect
