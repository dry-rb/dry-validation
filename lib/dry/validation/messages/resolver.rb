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

        # @api private
        def initialize(messages)
          @messages = messages
        end

        # Resolve a message
        #
        # @return [String]
        #
        # @api public
        def call(key, tokens: EMPTY_HASH, path:)
          msg_opts = tokens.merge(path: path)

          if path.empty?
            template = messages["rules.#{key}", path: path]
          else
            template = messages[key, msg_opts.merge(path: path.join(DOT))]
            template ||= messages[key, msg_opts.merge(path: path.last)]
          end

          unless template
            raise MissingMessageError, <<~STR
              Message template for #{key.inspect} under #{path.join(DOT).inspect} was not found
            STR
          end

          template.(template.data(tokens))
        end
        alias_method :[], :call
      end
    end
  end
end
