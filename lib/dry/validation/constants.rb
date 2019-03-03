require 'dry/core/constants'

module Dry
  module Validation
    include Dry::Core::Constants

    MissingMessageError = Class.new(StandardError)
    DuplicateSchemaError = Class.new(StandardError)
  end
end
