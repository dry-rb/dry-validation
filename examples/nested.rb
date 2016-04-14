require 'dry-validation'

schema = Dry::Validation.Schema do
  required(:address).schema do
    required(:city).required(min_size?: 3)

    required(:street).required

    required(:country).schema do
      required(:name).required
      required(:code).required
    end
  end
end

errors = schema.call({}).messages

puts errors.inspect

errors = schema.call(address: { city: 'NYC' }).messages

puts errors.inspect
