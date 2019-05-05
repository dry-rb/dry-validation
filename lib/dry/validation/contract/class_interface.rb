# frozen_string_literal: true

require 'dry/schema'
require 'dry/schema/messages'

require 'dry/validation/constants'

module Dry
  module Validation
    class Contract
      # Contract's class interface
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
        # @return [Config]
        #
        # @api public
        def config
          @config ||= Validation::Config.new
        end

        # Macros
        #
        # @return [Macros::Container]
        #
        # @api public
        def macros
          config.macros
        end

        # Define a params schema for your contract
        #
        # This type of schema is suitable for HTTP parameters
        #
        # @return [Dry::Schema::Params]
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
        # @api public
        def build(option = nil, &block)
          Class.new(self, &block).new(option)
        end

        # @api private
        def __schema__
          @__schema__ if defined?(@__schema__)
        end

        # @api private
        def rules
          @rules ||= EMPTY_ARRAY
            .dup
            .concat(superclass.respond_to?(:rules) ? superclass.rules : EMPTY_ARRAY)
        end

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
