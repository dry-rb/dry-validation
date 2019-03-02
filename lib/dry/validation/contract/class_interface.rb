require 'dry/schema'
require 'dry/validation/messages'
require 'dry/validation/constants'

module Dry
  module Validation
    class Contract
      # Contract's class interface
      #
      # @api public
      module ClassInterface
        # Define a params schema for your contract
        #
        # This type of schema is suitable for HTTP parameters
        #
        # @return [Dry::Schema::Params]
        #
        # @api public
        def params(&block)
          @__schema__ ||= Schema.Params(schema_opts, &block)
        end

        # Define a JSON schema for your contract
        #
        # This type of schema is suitable for JSON data
        #
        # @return [Dry::Schema::JSON]
        #
        # @api public
        def json(&block)
          @__schema__ ||= Schema.JSON(schema_opts, &block)
        end

        # Define a plain schema for your contract
        #
        # This type of schema does not offer coercion out of the box
        #
        # @return [Dry::Schema::Processor]
        #
        # @api public
        def schema(&block)
          @__schema__ ||= Schema.define(schema_opts, &block)
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
        # @return [Array<Rule>]
        #
        # @api public
        def rule(name, &block)
          rules << Rule.new(name: name, block: block)
          rules
        end

        # @api private
        def __schema__
          @__schema__ if defined?(@__schema__)
        end

        # @api private
        def rules
          @__rules__ ||= EMPTY_ARRAY
                         .dup
                         .concat(superclass.respond_to?(:rules) ? superclass.rules : EMPTY_ARRAY)
        end

        # @api private
        def messages
          @__messages__ ||= Messages.setup(config)
        end

        # @api private
        def build(option = nil, &block)
          Class.new(self, &block).new(option)
        end

        # @api private
        def schema_opts
          { parent: superclass&.__schema__, config: config }
        end
      end
    end
  end
end
