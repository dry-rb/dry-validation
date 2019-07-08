# frozen_string_literal: true

require 'dry/schema/key'
require 'dry/schema/key_map'

module Dry
  module Schema
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
          [name].product(members.map(&:to_dot_notation).flatten(1)).map { |e| e.join(DOT) }
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
