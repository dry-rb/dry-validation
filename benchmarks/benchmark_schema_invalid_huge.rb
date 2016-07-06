require 'benchmark/ips'

require 'active_model'
require 'dry-validation'

I18n.locale = :en
I18n.backend.load_translations

COUNT = ENV['COUNT'].to_i
FIELDS = COUNT.times.map { |i| :"field_#{i}" }

class User
  include ActiveModel::Validations

  attr_reader(*FIELDS)
  validates(*FIELDS, presence: true, numericality: { greater_than: FIELDS.size / 2 })

  def initialize(attrs)
    attrs.each do |field, value|
      instance_variable_set(:"@#{field}", value)
    end
  end
end

schema = Dry::Validation.Schema do
  configure do
    config.messages = :i18n
  end

  FIELDS.each do |field|
    required(field).value(:int?, gt?: FIELDS.size / 2)
  end
end

data = FIELDS.reduce({}) { |h, f| h.update(f => FIELDS.index(f) + 1) }

puts schema.(data).inspect
puts User.new(data).validate

Benchmark.ips do |x|
  x.report('ActiveModel::Validations') do
    user = User.new(data)
    user.validate
    user.errors
  end

  x.report('dry-validation / schema') do
    schema.(data).messages
  end

  x.compare!
end
