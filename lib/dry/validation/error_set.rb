# frozen_string_literal: true

require 'dry/schema/message_set'

require 'dry/validation/constants'
require 'dry/validation/error'

module Dry
  module Validation
    # ErrorSet is a specialized message set for handling validation errors
    #
    # @api public
    class ErrorSet < Schema::MessageSet
      include Enumerable

      # Add a new error
      #
      # This is used when result is being prepared
      #
      # @return [ErrorSet]
      #
      # @api private
      def add(error)
        messages << error
        initialize_placeholders!
        self
      end

      private

      # @api private
      def messages_map
        reduce(placeholders) do |hash, msg|
          node = msg.path.reduce(hash) { |a, e| a.is_a?(Hash) ? a[e] : a.last[e] }
          (node.size > 1 ? node[0] : node) << msg.to_s
          hash
        end
      end

      # @api private
      #
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/PerceivedComplexity
      def initialize_placeholders!
        @placeholders = uniq(&:path).map(&:path).each_with_object(EMPTY_HASH.dup) { |path, hash|
          curr_idx = 0
          last_idx = path.size - 1
          node = hash

          while curr_idx <= last_idx
            key = path[curr_idx]

            next_node =
              if node.is_a?(Array) && key.is_a?(Symbol)
                node_hash = (node << [] << {}).last
                node_hash[key] || (node_hash[key] = curr_idx < last_idx ? {} : [])
              else
                node[key] || (node[key] = curr_idx < last_idx ? {} : [])
              end

            node = next_node
            curr_idx += 1
          end
        }
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/PerceivedComplexity
    end
  end
end
