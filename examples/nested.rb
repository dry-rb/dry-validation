require 'dry-validation'

schema = Dry::Validation.Schema do
  required(:address).schema do
    required(:city).not_nil(min_size?: 3)

    required(:street).not_nil

    required(:country).schema do
      required(:name).not_nil
      required(:code).not_nil
    end
  end
end

errors = schema.call({}).messages

puts errors.inspect

errors = schema.call(address: { city: 'NYC' }).messages

puts errors.inspect
