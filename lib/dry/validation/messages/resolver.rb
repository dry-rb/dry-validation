# frozen_string_literal: true

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

        # Resolve Error object from provided args and path
        #
        # This is used internally by contracts when rules are applied
        #
        # @return [Error, Error::Localized]
        #
        # @api public
        def call(args:, tokens:, path:)
          if args.size.equal?(1)
            case (msg = args[0])
            when Symbol
              text = lambda { |locale|
                message(msg, path: path, tokens: tokens, locale: locale)
              }

              Error[text, path]
            when String
              Error[msg, path]
            end
          else
            Error[*args.reverse]
          end
        end
        alias_method :[], :call

        # Resolve a message
        #
        # @return [String]
        #
        # @api public
        def message(rule, tokens: EMPTY_HASH, path:, locale: self.locale)
          keys = path.to_a.compact
          msg_opts = tokens.merge(path: keys, locale: locale)

          if keys.empty?
            template = messages["rules.#{rule}", msg_opts]
          else
            template = messages[rule, msg_opts.merge(path: keys.join(DOT))]
            template ||= messages[rule, msg_opts.merge(path: keys.last)]
          end

          unless template
            raise MissingMessageError, <<~STR
              Message template for #{rule.inspect} under #{keys.join(DOT).inspect} was not found
            STR
          end

          template.(template.data(tokens))
        end
      end
    end
  end
end
