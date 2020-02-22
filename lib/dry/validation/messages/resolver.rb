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

          options = msg_opts.merge(parse_tokens(tokens))

          message =
            if keys.empty?
              messages["rules.#{rule}", options]
            else
              messages[rule, options.merge(path: keys.join(DOT))] ||
                messages[rule, options.merge(path: keys.last)]
            end

          unless message
            raise MissingMessageError, <<~STR
              Message template for #{rule.inspect} under #{keys.join(DOT).inspect} was not found
            STR
          end

          text, meta = message.values_at(:text, :meta)

          [full ? "#{messages.rule(keys.last, options)} #{text}" : text, meta]
        end
        # rubocop:enable Metrics/AbcSize

        private

        def parse_tokens(tokens)
          Hash[
            tokens.map do |key, token|
              [key, parse_token(token)]
            end
          ]
        end

        def parse_token(token)
          case token
          when Array
            token.join(', ')
          else
            token
          end
        end
      end
    end
  end
end
