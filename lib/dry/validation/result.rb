require 'dry/validation/constants'

module Dry
  module Validation
    class Result
      def self.new(params, errors = EMPTY_HASH.dup)
        result = super
        yield(result) if block_given?
        result.freeze
      end

      attr_reader :params

      attr_reader :errors

      def initialize(params, errors)
        @params = params
        @errors = errors.update(params.errors)
      end

      def error?(key)
        params.error?(key)
      end

      def add_error(key, message)
        (errors[key] ||= EMPTY_ARRAY.dup) << message
        self
      end

      def [](key)
        params[key]
      end

      def update(new_errors)
        errors.update(new_errors)
      end
    end
  end
end
