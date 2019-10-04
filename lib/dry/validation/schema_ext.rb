# frozen_string_literal: true

require 'dry/schema/key'
require 'dry/schema/key_map'

module Dry
  module Schema
    class Path
      # @api private
      def multi_value?
        last.is_a?(Array)
      end

      # @api private
      def expand
        to_a[0..-2].product(last).map { |spec| self.class[spec] }
      end
    end

    # @api private
    #
    # TODO: this should be moved to dry-schema at some point
    class Key
      # @api private
      def to_dot_notation
        [name.to_s]
      end

      # @api private
      class Hash < Key
        # @api private
        def to_dot_notation
          [name].product(members.flat_map(&:to_dot_notation)).map { |e| e.join(DOT) }
        end
      end
    end

    # @api private
    class KeyMap
      # @api private
      def to_dot_notation
        @to_dot_notation ||= map(&:to_dot_notation).flatten
      end
    end
  end
end
