# frozen_string_literal: true

module Dry
  module Validation
    # Configuration for contracts
    #
    # @see Contract#config
    #
    # @api public
    class Config < Schema::Config
      setting :macros, default: Macros::Container.new, constructor: :dup.to_proc

      # @api private
      def dup
        config = super
        config.macros = macros.dup
        config
      end
    end
  end
end
