# frozen_string_literal: true

require 'dry/core/constants'

module Dry
  module Validation
    include Dry::Core::Constants

    DOT = '.'

    MissingMessageError = Class.new(StandardError)
    DuplicateSchemaError = Class.new(StandardError)
  end
end
