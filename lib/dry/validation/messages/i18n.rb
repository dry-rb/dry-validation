require 'i18n'
require 'dry/validation/messages/abstract'

module Dry
  module Validation
    class Messages::I18n < Messages::Abstract
      attr_reader :t

      ::I18n.load_path.concat(config.paths)

      def initialize
        @t = I18n.method(:t)
      end

      def get(key, options = {})
        t.(key, options)
      end

      def key?(key, options)
        ::I18n.exists?(key, options.fetch(:locale, I18n.default_locale))
      end
    end
  end
end
