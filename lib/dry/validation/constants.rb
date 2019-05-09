# frozen_string_literal: true

require 'dry/core/constants'

module Dry
  module Validation
    include Dry::Core::Constants

    DOT = '.'

    # Error raised when `rule` specifies one or more keys that the schema doesn't specify
    InvalidKeysError = Class.new(StandardError)

    # Error raised when a localized message was not found
    MissingMessageError = Class.new(StandardError)

    # Error raised when trying to define a schema in a contract class that already has a schema
    DuplicateSchemaError = Class.new(StandardError)

    # Error raised during initialization of a contract that has no schema defined
    SchemaMissingError = Class.new(StandardError) do
      # @api private
      def initialize(klass)
        super("#{klass} cannot be instantiated without a schema defined")
      end
    end
  end
end
