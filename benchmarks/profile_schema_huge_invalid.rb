require_relative 'suite'
require 'hotch'

require 'dry-validation'

I18n.locale = :en
I18n.backend.load_translations

COUNT = ENV['COUNT'].to_i
FIELDS = COUNT.times.map { |i| :"field_#{i}" }

schema = Dry::Validation.Schema do
  configure do
    config.messages = :i18n
  end

  FIELDS.each do |field|
    required(field).filled(gt?: FIELDS.size / 2)
  end
end

data = FIELDS.reduce({}) { |h, f| h.update(f => FIELDS.index(f) + 1) }

puts schema.(data).inspect

Hotch() do
  100.times do
    schema.(data).messages
  end
end
