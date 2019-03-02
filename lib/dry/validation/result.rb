require 'dry/validation/constants'

module Dry
  module Validation
    class Result
      def self.new(params, errors = EMPTY_HASH.dup)
        result = super
        yield(result) if block_given?
        result.freeze
      end

      attr_reader :values

      attr_reader :errors

      def initialize(values, errors)
        @values = values
        @errors = errors.update(values.errors)
      end

      def error?(key)
        values.error?(key)
      end

      def add_error(key, message)
        (errors[key] ||= EMPTY_ARRAY.dup) << message
        self
      end

      def [](key)
        values[key]
      end

      def to_h
        values.to_h
      end
      alias_method :to_hash, :to_h

      def update(new_errors)
        errors.update(new_errors)
      end
    end
  end
end
