require 'i18n'

module Dry
  module Validation
    class Messages::I18n
      attr_reader :t

      def initialize
        @t = I18n.method(:t)
      end

      def exists?(key)
        I18n.exists?(key)
      end

      def lookup(predicate, rule, predicate_arg = nil)
        keys = [
          "errors.attributes.#{rule}.#{predicate}",
          "errors.#{predicate}"
        ]

        key = keys.detect { |name| exists?(name) }

        message = t.(key)

        if message.is_a?(Hash)
          message.fetch(predicate_arg.class.name.downcase.to_sym) {
            message.fetch(:default)
          }
        else
          message
        end
      end
    end
  end
end
