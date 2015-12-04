require 'i18n'
require 'dry/validation/messages/abstract'

module Dry
  module Validation
    class Messages::I18n < Messages::Abstract
      attr_reader :t

      def initialize
        @t = I18n.method(:t)
      end

      def get(key)
        t.(key)
      end
      alias_method :[], :call

      def key?(key)
        I18n.exists?(key)
      end
    end
  end
end
