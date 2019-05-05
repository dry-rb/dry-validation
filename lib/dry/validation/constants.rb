# frozen_string_literal: true

require 'dry/core/constants'

module Dry
  module Validation
    include Dry::Core::Constants

    DOT = '.'

    # Error raised when a localized message was not found
    MissingMessageError = Class.new(StandardError)

    # Error raised when trying to define a schema in a contract class that already has a schema
    DuplicateSchemaError = Class.new(StandardError)
  end
end
