# frozen_string_literal: true

require 'dry/schema/message_set'

require 'dry/validation/constants'
require 'dry/validation/message'

module Dry
  module Validation
    # MessageSet is a specialized message set for handling validation messages
    #
    # @api public
    class MessageSet < Schema::MessageSet
      # Return the source set of messages used to produce final evaluated messages
      #
      # @return [Array<Message, Message::Localized, Schema::Message>]
      #
      # @api private
      attr_reader :source_messages

      # Configured locale
      #
      # @return [Symbol]
      #
      # @api public
      attr_reader :locale

      # @api private
      def initialize(messages, options = EMPTY_HASH)
        @locale = options[:locale]
        @source_messages = options.fetch(:source) { messages.dup }
        super
      end

      # Return a new message set using updated options
      #
      # @return [MessageSet]
      #
      # @api private
      def with(other, new_options = EMPTY_HASH)
        return self if new_options.empty? && other.eql?(messages)

        self.class.new(
          other | select { |err| err.is_a?(Message) },
          options.merge(source: source_messages, **new_options)
        ).freeze
      end

      # Add a new message
      #
      # This is used when result is being prepared
      #
      # @return [MessageSet]
      #
      # @api private
      def add(message)
        @empty = nil
        source_messages << message
        messages << message
        initialize_placeholders!
        self
      end

      # Filter message set using provided predicates
      #
      # This method is open to any predicate because messages can be anything that
      # implements Message API, thus they can implement whatever predicates you
      # may need.
      #
      # @example get a list of base messages
      #   message_set = contract.(input).errors
      #   message_set.filter(:base?)
      #
      # @param [Array<Symbol>] predicates
      #
      # @return [MessageSet]
      #
      # @api public
      def filter(*predicates)
        messages = select { |msg|
          predicates.all? { |predicate| msg.respond_to?(predicate) && msg.public_send(predicate) }
        }
        self.class.new(messages)
      end

      # @api private
      def freeze
        source_messages.select { |err| err.respond_to?(:evaluate) }.each do |err|
          idx = source_messages.index(err)
          msg = err.evaluate(locale: locale, full: options[:full])
          messages[idx] = msg
        end
        to_h
        self
      end

      private

      # @api private
      def unique_paths
        source_messages.uniq(&:path).map(&:path)
      end

      # @api private
      def messages_map
        @messages_map ||= reduce(placeholders) { |hash, msg|
          node = msg.path.reduce(hash) { |a, e| a.is_a?(Hash) ? a[e] : a.last[e] }
          (node[0].is_a?(::Array) ? node[0] : node) << msg.dump
          hash
        }
      end

      # @api private
      #
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/PerceivedComplexity
      def initialize_placeholders!
        @placeholders = unique_paths.sort_by(&:size).each_with_object(EMPTY_HASH.dup) { |path, hash|
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
