# frozen_string_literal: true

require "dry/schema/config"
require "dry/validation/macros"
require "dry/configurable/version"

module Dry
  module Validation
    # Configuration for contracts
    #
    # @see Contract#config
    #
    # @api public
    class Config < Schema::Config
      if Dry::Configurable::VERSION < "0.13"
        setting :macros, Macros::Container.new, constructor: :dup.to_proc
      else
        setting :macros, default: Macros::Container.new, constructor: :dup.to_proc
      end

      # @api private
      def dup
        config = super
        config.macros = macros.dup
        config
      end
    end
  end
end
