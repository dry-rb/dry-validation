require 'i18n'

module Dry
  module Validation
    class Messages::I18n
      attr_reader :t

      def initialize
        @t = I18n.method(:t)
      end

      def lookup(predicate, arg)
        t.("errors.#{predicate}")
      end
    end
  end
end
