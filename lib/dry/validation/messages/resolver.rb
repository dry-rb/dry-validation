# frozen_string_literal: true

module Dry
  module Validation
    module Messages
      FULL_MESSAGE_WHITESPACE = Dry::Schema::MessageCompiler::FULL_MESSAGE_WHITESPACE

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
            Message[->(**opts) { [message_text(message, path: path, **opts), meta] }, path, meta]
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
        # rubocop:disable Metrics/PerceivedComplexity
        def message(rule, path:, tokens: EMPTY_HASH, locale: nil, full: false)
          keys = path.to_a.compact
          msg_opts = tokens.merge(path: keys, locale: locale || messages.default_locale)

          if keys.empty?
            template, meta = messages["rules.#{rule}", msg_opts]
          else
            template, meta = messages[rule, msg_opts.merge(path: keys.join(DOT))]
            template, meta = messages[rule, msg_opts.merge(path: keys.last)] unless template
          end

          if !template && keys.size > 1
            non_index_keys = keys.reject { |k| k.is_a?(Integer) }
            template, meta = messages[rule, msg_opts.merge(path: non_index_keys.join(DOT))]
          end

          unless template
            raise MissingMessageError, <<~STR
              Message template for #{rule.inspect} under #{keys.join(DOT).inspect} was not found
            STR
          end

          parsed_tokens = parse_tokens(tokens)
          text = template.(template.data(parsed_tokens))

          [message_text(text, path: path, locale: locale, full: full), meta]
        end
        # rubocop:enable Metrics/PerceivedComplexity
        # rubocop:enable Metrics/AbcSize

        private

        def message_text(text, path:, locale: nil, full: false)
          return text unless full

          key = key_text(path: path, locale: locale)

          [key, text].compact.join(FULL_MESSAGE_WHITESPACE[locale])
        end

        def key_text(path:, locale: nil)
          locale ||= messages.default_locale

          keys = path.to_a.compact
          msg_opts = {path: keys, locale: locale}

          messages.rule(keys.last, msg_opts) || keys.last
        end

        def parse_tokens(tokens)
          tokens.transform_values { parse_token(_1) }
        end

        def parse_token(token)
          case token
          when Array
            token.join(", ")
          else
            token
          end
        end
      end
    end
  end
end
