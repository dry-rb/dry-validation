# frozen_string_literal: true

require 'dry/schema/config'
require 'dry/validation/macros'

module Dry
  module Validation
    # Configuration for contracts
    #
    # @see Contract#config
    #
    # @api public
    class Config < Schema::Config
      setting :locale, :en
      setting :macros, Macros::Container.new, &:dup

      # @api private
      def macros
        config.macros
      end

      # @api private
      def locale
        config.locale
      end

      # @api private
      def respond_to_missing?(meth, include_private = false)
        super || config.respond_to?(meth, include_private)
      end

      private

      # @api private
      def method_missing(meth, *args, &block)
        super unless config.respond_to?(meth)
        config.public_send(meth, *args)
      end
    end
  end
end
