# frozen_string_literal: true

require 'dry/schema/path'

module Dry
  module Validation
    class Composition
      # Adds steps to a composition via #contract and #path methods
      #
      # @api private
      class Builder
        # @return [Composition]
        #
        # @api private
        attr_reader :composition

        # @return [Schema::Path]
        #
        # @api private
        attr_reader :prefix

        def initialize(composition, prefix = nil)
          @composition = composition
          @prefix = Schema::Path[prefix] if prefix
        end

        def contract(contract, path: nil)
          composition.add_step contract, prefixed(path)
        end

        def path(path, &block)
          self.class.new(composition, prefixed(path)).instance_eval(&block)
        end

        private

        def prefixed(path)
          path = Schema::Path[path] if path
          path = Schema::Path.new([*prefix, *path]) if prefix
          path
        end
      end
    end
  end
end
