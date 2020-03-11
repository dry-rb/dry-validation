# frozen_string_literal: true

require "dry/schema/config"
require "dry/validation/macros"

module Dry
  module Validation
    # Configuration for contracts
    #
    # @see Contract#config
    #
    # @api public
    class Config < Schema::Config
      setting :macros, Macros::Container.new, &:dup

      # @api private
      def dup
        config = super
        config.macros = macros.dup
        config
      end
    end
  end
end
