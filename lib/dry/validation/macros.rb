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
      # @api public
      class Container
        include Dry::Container::Mixin

        # Register a new macro
        #
        # @example in a contract class
        #   class MyContract < Dry::Validation::Contract
        #     macros.register(:even_numbers) do
        #       key.failure('all numbers must be even') unless values[key_name].all?(&:even?)
        #     end
        #   end
        #
        # @return [self]
        #
        # @api public
        def register(name, &block)
          super(name, block, call: false)
          self
        end
      end

      # Return a registered macro
      #
      # @return [Proc]
      #
      # @api public
      def self.[](name)
        container[name]
      end

      # Register a global macro
      #
      # @see Container#register
      #
      # @return [Macros]
      #
      # @api public
      def self.register(*args, &block)
        container.register(*args, &block)
        self
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
