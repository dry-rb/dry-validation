# frozen_string_literal: true

require 'dry/validation/message'

module Dry
  module Validation
    module Messages
      # Resolve translated messages from failure arguments
      #
      # @api public
      class Resolver
        # @!attribute [r] messages
        #   @return [Messages::I18n, Messages::YAML] messages backend
        #   @api private
        attr_reader :messages

        # @api private
        def initialize(messages)
          @messages = messages
        end

        # Resolve Message object from provided args and path
        #
        # This is used internally by contracts when rules are applied
        # If message argument is a Hash, then it MUST have a :text key,
        # which value will be used as the message value
        #
        # @return [Message, Message::Localized]
        #
        # @api public
        def call(message:, tokens:, path:, meta: EMPTY_HASH)
          case message
          when Symbol
            Message[->(**opts) { message(message, path: path, tokens: tokens, **opts) }, path, meta]
          when String
            Message[message, path, meta]
          when Hash
            meta = message.dup
            text = meta.delete(:text) { |key|
              raise ArgumentError, <<~STR
                +message+ Hash must contain :#{key} key (#{message.inspect} given)
              STR
            }

            call(message: text, tokens: tokens, path: path, meta: meta)
          else
            raise ArgumentError, <<~STR
              +message+ must be either a Symbol, String or Hash (#{message.inspect} given)
            STR
          end
        end
        alias_method :[], :call

        # Resolve a message
        #
        # @return [String]
        #
        # @api public
        #
        # rubocop:disable Metrics/AbcSize
        def message(rule, tokens: EMPTY_HASH, locale: nil, full: false, path:)
          keys = path.to_a.compact
          msg_opts = tokens.merge(path: keys, locale: locale || messages.default_locale)

          if keys.empty?
            template, meta = messages["rules.#{rule}", msg_opts]
          else
            template, meta = messages[rule, msg_opts.merge(path: keys.join(DOT))]
            template, meta = messages[rule, msg_opts.merge(path: keys.last)] unless template
          end

          unless template
            raise MissingMessageError, <<~STR
              Message template for #{rule.inspect} under #{keys.join(DOT).inspect} was not found
            STR
          end

          text = template.(template.data(tokens))

          [full ? "#{messages.rule(keys.last, msg_opts)} #{text}" : text, meta]
        end
        # rubocop:enable Metrics/AbcSize
      end
    end
  end
end
