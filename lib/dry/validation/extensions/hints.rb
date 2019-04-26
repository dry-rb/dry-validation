# frozen_string_literal: true

require 'dry/monads/result'

module Dry
  module Validation
    # Hints extension for contract results
    #
    # @example
    #   Dry::Validation.load_extensions(:hints)
    #
    #   contract = Dry::Validation::Contract.build do
    #     schema do
    #       required(:name).filled(:string, min_size?: 2..4)
    #     end
    #   end
    #
    #   contract.call(name: "fo").hints
    #   # {:name=>["size must be within 2 - 4"]}
    #
    #   contract.call(name: "").messages
    #   # {:name=>["must be filled", "size must be within 2 - 4"]}
    #
    # @api public
    module Hints
      module ResultExtensions
        # Return error messages excluding hints
        #
        # @return [MessageSet]
        #
        # @api public
        def errors(new_opts = EMPTY_HASH)
          opts = new_opts.merge(hints: false)
          @errors.with(schema_errors(opts), opts)
        end

        # Return errors and hints
        #
        # @return [MessageSet]
        #
        # @api public
        def messages(new_opts = EMPTY_HASH)
          errors.with(hints.to_a, options.merge(**new_opts))
        end

        # Return hint messages
        #
        # @return [MessageSet]
        #
        # @api public
        def hints(new_opts = EMPTY_HASH)
          values.hints(new_opts)
        end
      end

      Dry::Schema.load_extensions(:hints)

      Result.prepend(ResultExtensions)
    end
  end
end
