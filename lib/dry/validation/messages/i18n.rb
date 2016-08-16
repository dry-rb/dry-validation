require 'i18n'
require 'dry/validation/messages/abstract'

module Dry
  module Validation
    class Messages::I18n < Messages::Abstract
      attr_reader :t

      ::I18n.load_path.concat(config.paths)

      def initialize
        super
        @t = I18n.method(:t)
      end

      def get(key, options = {})
        t.(key, options) if key
      end

      def key?(key, options)
        ::I18n.exists?(key, options.fetch(:locale, default_locale)) ||
        ::I18n.exists?(key, I18n.default_locale)
      end

      def merge(path)
        ::I18n.load_path << path
        self
      end

      def default_locale
        I18n.locale || I18n.default_locale || super
      end
    end
  end
end
