require 'i18n'
require 'dry/validation/messages/abstract'

module Dry
  module Validation
    class Messages::I18n < Messages::Abstract
      attr_reader :t

      def initialize
        @t = I18n.method(:t)
      end

      def get(key, options = {})
        t.(key, options)
      end

      def key?(key)
        I18n.exists?(key)
      end
    end
  end
end
