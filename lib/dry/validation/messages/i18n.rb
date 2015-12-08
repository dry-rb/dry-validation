require 'i18n'
require 'dry/validation/messages/abstract'

module Dry
  module Validation
    class Messages::I18n < Messages::Abstract
      attr_reader :t

      ::I18n.load_path << config.path

      def initialize
        @t = I18n.method(:t)
      end

      def get(key, options = {})
        t.(key, options)
      end

      def key?(key, options)
        ::I18n.exists?(key, options.fetch(:locale, I18n.default_locale))
      end

      def merge(path)
        ::I18n.load_path << path
        self
      end
    end
  end
end
