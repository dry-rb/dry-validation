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
      unless Dry::Configurable::VERSION < "0.13"
        def self.setting(name, default = Undefined, **opts, &block)
          return super if default.equal?(Undefined)
          super(name, **opts.merge(default: default), &block)
        end
      end

      setting :macros, Macros::Container.new, constructor: :dup.to_proc

      # @api private
      def dup
        config = super
        config.macros = macros.dup
        config
      end
    end
  end
end
