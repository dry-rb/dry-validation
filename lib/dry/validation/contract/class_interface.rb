# frozen_string_literal: true

require 'dry/schema'
require 'dry/schema/messages'

require 'dry/validation/constants'

module Dry
  module Validation
    class Contract
      # Contract's class interface
      #
      # @see Contract
      #
      # @api public
      module ClassInterface
        # @api private
        def inherited(klass)
          super
          klass.instance_variable_set('@config', config.dup)
        end

        # Configuration
        #
        # @example
        #   class MyContract < Dry::Validation::Contract
        #     config.messages.backend = :i18n
        #   end
        #
        # @return [Config]
        #
        # @api public
        def config
          @config ||= Validation::Config.new
        end

        # Return macros registered for this class
        #
        # @return [Macros::Container]
        #
        # @api public
        def macros
          config.macros
        end

        # Register a new global macro
        #
        # Macros will be available for the contract class and its descendants
        #
        # @example
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
        def register_macro(name, &block)
          macros.register(name, &block)
          self
        end

        # Define a params schema for your contract
        #
        # This type of schema is suitable for HTTP parameters
        #
        # @return [Dry::Schema::Params]
        # @see https://dry-rb.org/gems/dry-schema/params/
        #
        # @api public
        def params(&block)
          define(:Params, &block)
        end

        # Define a JSON schema for your contract
        #
        # This type of schema is suitable for JSON data
        #
        # @return [Dry::Schema::JSON]
        # @see https://dry-rb.org/gems/dry-schema/json/
        #
        # @api public
        def json(&block)
          define(:JSON, &block)
        end

        # Define a plain schema for your contract
        #
        # This type of schema does not offer coercion out of the box
        #
        # @return [Dry::Schema::Processor]
        # @see https://dry-rb.org/gems/dry-schema/
        #
        # @api public
        def schema(&block)
          define(:schema, &block)
        end

        # Define a rule for your contract
        #
        # @example using a symbol
        #   rule(:age) do
        #     failure('must be at least 18') if values[:age] < 18
        #   end
        #
        # @example using a path to a value and a custom predicate
        #   rule('address.street') do
        #     failure('please provide a valid street address') if valid_street?(values[:street])
        #   end
        #
        # @return [Rule]
        #
        # @api public
        def rule(*keys, &block)
          Rule.new(keys: keys, block: block).tap do |rule|
            rules << rule
          end
        end

        # A shortcut that can be used to define contracts that won't be reused or inherited
        #
        # @example
        #   my_contract = Dry::Validation::Contract.build do
        #     params do
        #       required(:name).filled(:string)
        #     end
        #   end
        #
        #   my_contract.call(name: "Jane")
        #
        # @return [Contract]
        #
        # @api public
        def build(options = EMPTY_HASH, &block)
          Class.new(self, &block).new(options)
        end

        # @api private
        def __schema__
          @__schema__ if defined?(@__schema__)
        end

        # Return rules defined in this class
        #
        # @return [Array<Rule>]
        #
        # @api private
        def rules
          @rules ||= EMPTY_ARRAY
            .dup
            .concat(superclass.respond_to?(:rules) ? superclass.rules : EMPTY_ARRAY)
        end

        # Return messages configured for this class
        #
        # @return [Dry::Schema::Messages]
        #
        # @api private
        def messages
          @messages ||= Schema::Messages.setup(config.messages)
        end

        private

        # @api private
        def schema_opts
          { parent: superclass&.__schema__, config: config }
        end

        # @api private
        def define(method_name, &block)
          if defined?(@__schema__)
            raise ::Dry::Validation::DuplicateSchemaError, 'Schema has already been defined'
          end

          case method_name
          when :schema
            @__schema__ = Schema.define(schema_opts, &block)
          when :Params
            @__schema__ = Schema.Params(schema_opts, &block)
          when :JSON
            @__schema__ = Schema.JSON(schema_opts, &block)
          end
        end
      end
    end
  end
end
