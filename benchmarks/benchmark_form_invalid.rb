# frozen_string_literal: true

require 'benchmark/ips'
require 'active_model'

require 'i18n'
require 'dry-validation'
require 'byebug'

class User
  include ActiveModel::Validations

  attr_reader :email, :age

  validates :email, :age, presence: true
  validates :age, numericality: { greater_than: 18 }

  def initialize(attrs)
    @email, @age = attrs.values_at('email', 'age')
  end
end

contract = Dry::Validation::Contract.build do
  config.messages = :i18n

  params do
    required(:email).filled(:string)
    required(:age).filled(:integer)
  end

  rule(:age) do
    failure('must be greater than 18') if values[:age] <= 18
  end
end

params = { 'email' => '', 'age' => '18' }

puts contract.(params).inspect
puts User.new(params).validate

Benchmark.ips do |x|
  x.report('ActiveModel::Validations') do
    user = User.new(params)
    user.validate
    user.errors
  end

  x.report('dry-validation') do
    contract.(params).errors
  end

  x.compare!
end
