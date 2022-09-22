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
      setting :macros, default: Macros::Container.new, constructor: :dup.to_proc

      # @api private
      def dup
        super.configure { |c| c.macros = macros.dup }
      end
    end
  end
end
