# frozen_string_literal: true

require 'dry/validation/result_interface'

module Dry
  module Validation
    class Composition
      # A Composition::Result is built from many results with optional
      # input prefixes.
      #
      # @see ResultInterface
      #
      # @api public
      class Result
        include ResultInterface

        include Dry::Equalizer(:errors, :values, inspect: false)

        # Build a new result
        #
        # @param [Dry::Schema::Result] schema_result
        #
        # @api private
        def self.new(options = EMPTY_HASH)
          result = super
          yield(result) if block_given?
          result.freeze
        end

        # Result options
        #
        # @return [Hash]
        #
        # @api private
        attr_reader :options

        # Result values
        #
        # @return [Values]
        #
        # @api public
        attr_reader :values

        # prefixed results
        #
        # @return [Array[Schema::Path, Result]]
        #
        # @api private
        attr_reader :prefixed_results

        # Initialize a new result
        #
        # @api private
        def initialize(options)
          @options = options
          @values  = Values.new({})
          @errors  = MessageSet.new([], options)

          # prefixed results is only necessary so that we can rebuild error
          # messages when passed options to #errors.
          #
          # TODO: can we see a way of having a MessageSet be able to rebuild
          #       itself given new options?
          @prefixed_results = []
        end

        # Freeze values and errors
        #
        # @api private
        def freeze
          values.freeze
          errors.freeze
          @prefixed_results.freeze
          super
        end

        # Add a result, merging its values, and adding its errors, optionally prefixed
        #
        # @api private
        def add_result(result, prefix = nil)
          add_values(result.to_h, prefix)
          prefixed_results << [prefix, result]
          @errors = build_errors(options)
          self
        end

        # Get error set
        #
        # @!macro errors-options
        #   @param [Hash] new_options
        #   @option new_options [Symbol] :locale Set locale for messages
        #   @option new_options [Boolean] :hints Enable/disable hints
        #   @option new_options [Boolean] :full Get messages that include key names
        #
        # @return [MessageSet]
        #
        # @api public
        def errors(new_options = EMPTY_HASH)
          new_options.empty? ? @errors : build_errors(new_options)
        end

        private

        # merge the supplied hash into our values
        #
        # @api private
        def add_values(hash, prefix)
          hash = prefixed_hash(hash, prefix) if prefix
          @values = Values.new(merge_hashes(@values.to_h, hash))
        end

        # build the errors from scratch using the supplied options
        #
        # @api private
        def build_errors(options)
          empty_set = MessageSet.new([], options)
          prefixed_results.each_with_object(empty_set) do |(prefix, result), errors|
            result.errors(options).each do |error|
              path = prefix ? Schema::Path[prefix].to_a + error.path : error.path
              errors.add Message[error.text, path, error.meta]
            end
          end
        end

        # prefix the passed hash input with the given path prefix
        #
        # @example
        #   prefixed_hash({foo: 1}, 'bar.baz') # => { bar: { baz: { foo: 1 } } }
        #
        # @api private
        def prefixed_hash(input, prefix)
          prefix = Schema::Path[prefix].to_a
          output = prefix.reverse.reduce({}) { |m, key| { key => m } }
          output.dig(*prefix).merge!(input)
          output
        end

        # merge hashes, merging values only in the case of a conflict where both are hash
        #
        # @example
        #
        #   l = { a: { b: 1 }, d: [1] }
        #   r = { a: { c: 2 }, d: [2] }
        #
        #   merge_hashes(l, r) # => { a: { b: 1, c: 2 }, d: [2] }
        #
        # @api private
        def merge_hashes(left, right)
          left.merge(right) do |_key, left_val, right_val|
            if left_val.is_a?(Hash) && right_val.is_a?(Hash)
              merge_hashes(left_val, right_val)
            else
              right_val
            end
          end
        end
      end
    end
  end
end
