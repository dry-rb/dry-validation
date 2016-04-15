require 'dry-validation'

schema = Dry::Validation.Schema do
  required(:address).schema do
    required(:city).filled(min_size?: 3)

    required(:street).filled

    required(:country).schema do
      required(:name).filled
      required(:code).filled
    end
  end
end

errors = schema.call({}).messages

puts errors.inspect

errors = schema.call(address: { city: 'NYC' }).messages

puts errors.inspect
