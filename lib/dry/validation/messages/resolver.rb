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

        # @!attribute [r] locale
        #   @return [Symbol] current locale
        #   @api private
        attr_reader :locale

        # @api private
        def initialize(messages, locale = :en)
          @messages = messages
          @locale = locale
        end

        # Resolve Message object from provided args and path
        #
        # This is used internally by contracts when rules are applied
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
            text = meta.delete(:text)
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
        def message(rule, tokens: EMPTY_HASH, path:, locale: self.locale, full: false)
          keys = path.to_a.compact
          msg_opts = tokens.merge(path: keys, locale: locale)

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
      end
    end
  end
end
