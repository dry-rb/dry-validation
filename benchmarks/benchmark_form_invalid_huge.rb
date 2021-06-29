# frozen_string_literal: true

require "benchmark/ips"
require "active_model"

require "i18n"
require "dry-validation"
require "byebug"

COUNT = (ENV["COUNT"] || 100).to_i
FIELDS = COUNT.times.map { |i| :"field_#{i}" }

class User
  include ActiveModel::Validations

  attr_reader(*FIELDS)
  validates(*FIELDS, presence: true, numericality: {greater_than: FIELDS.size / 2})

  def initialize(attrs)
    attrs.each do |field, value|
      instance_variable_set(:"@#{field}", value)
    end
  end
end

contract = Dry::Validation::Contract.build do
  params do
    FIELDS.each do |field|
      required(field).value(:integer, gt?: FIELDS.size / 2)
    end
  end
end

params = FIELDS.reduce({}) { |h, f| h.update(f => FIELDS.index(f) + 1) }

puts contract.(params).inspect
puts User.new(params).validate

Benchmark.ips do |x|
  x.report("ActiveModel::Validations") do
    user = User.new(params)
    user.validate
    user.errors.messages
  end

  x.report("dry-validation / schema") do
    contract.(params).errors
  end

  x.compare!
end
