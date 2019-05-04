# frozen_string_literal: true

require 'dry/container/mixin'

module Dry
  module Validation
    # API for registering and accessing Rule macros
    #
    # @api public
    module Macros
      extend Container::Mixin

      # @api public
      def self.register(name, &block)
        super(name, block, call: false)
      end

      # Acceptance macro
      #
      # @api public
      register(:acceptance) do
        key.failure(:acceptance, key: key_name) unless values[key_name].equal?(true)
      end
    end
  end
end
