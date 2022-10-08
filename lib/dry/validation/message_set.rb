# frozen_string_literal: true

require "dry/validation/constants"

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
          idx = messages.index(err) || source_messages.index(err)
          msg = err.evaluate(locale: locale, full: options[:full])
          messages[idx] = msg
        end
        to_h
        self
      end
    end
  end
end
