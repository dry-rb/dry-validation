# frozen_string_literal: true

require 'dry/container'

module Dry
  module Validation
    # API for registering and accessing Rule macros
    #
    # @api public
    module Macros
      # Registry for macros
      #
      # @api private
      class Container
        include Dry::Container::Mixin

        # @api private
        def register(name, &block)
          super(name, block, call: false)
        end
      end

      # @api public
      def self.[](name)
        container[name]
      end

      # @api public
      def self.register(*args, &block)
        container.register(*args, &block)
      end

      # @api private
      def self.container
        @container ||= Container.new
      end
    end

    # Acceptance macro
    #
    # @api public
    Macros.register(:acceptance) do
      key.failure(:acceptance, key: key_name) unless values[key_name].equal?(true)
    end
  end
end
