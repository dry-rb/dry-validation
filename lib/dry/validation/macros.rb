# frozen_string_literal: true

module Dry
  module Validation
    # API for registering and accessing Rule macros
    #
    # @api public
    module Macros
      module Registrar
        # Register a macro
        #
        # @example register a global macro
        #   Dry::Validation.register_macro(:even_numbers) do
        #     key.failure('all numbers must be even') unless values[key_name].all?(&:even?)
        #   end
        #
        # @example register a contract macro
        #   class MyContract < Dry::Validation::Contract
        #     register_macro(:even_numbers) do
        #       key.failure('all numbers must be even') unless values[key_name].all?(&:even?)
        #     end
        #   end
        #
        # @param [Symbol] name The name of the macro
        # @param [Array] args Optional default positional arguments for the macro
        #
        # @return [self]
        #
        # @see Macro
        #
        # @api public
        def register_macro(name, *args, &block)
          macros.register(name, *args, &block)
          self
        end
      end

      # Registry for macros
      #
      # @api public
      class Container
        include Core::Container::Mixin

        # Register a new macro
        #
        # @example in a contract class
        #   class MyContract < Dry::Validation::Contract
        #     register_macro(:even_numbers) do
        #       key.failure('all numbers must be even') unless values[key_name].all?(&:even?)
        #     end
        #   end
        #
        # @param [Symbol] name The name of the macro
        #
        # @return [self]
        #
        # @api public
        def register(name, *args, &block)
          macro = Macro.new(name, args: args, block: block)
          super(name, macro, call: false, &nil)
          self
        end
      end

      # Return a registered macro
      #
      # @param [Symbol] name The name of the macro
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
      def self.register(name, *args, &block)
        container.register(name, *args, &block)
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
