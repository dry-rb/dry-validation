# frozen_string_literal: true

module Dry
  module Validation
    # Hints extension
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
      # Hints extensions for Result
      #
      # @api public
      module ResultExtensions
        # Return error messages excluding hints
        #
        # @macro errors-options
        # @return [MessageSet]
        #
        # @api public
        def errors(new_options = EMPTY_HASH)
          opts = new_options.merge(hints: false)
          @errors.with(schema_errors(opts), opts)
        end

        # Return errors and hints
        #
        # @macro errors-options
        #
        # @return [MessageSet]
        #
        # @api public
        def messages(new_options = EMPTY_HASH)
          errors.with(hints(new_options).to_a, options.merge(**new_options))
        end

        # Return hint messages
        #
        # @macro errors-options
        #
        # @return [MessageSet]
        #
        # @api public
        def hints(new_options = EMPTY_HASH)
          schema_result.hints(new_options)
        end
      end

      Dry::Schema.load_extensions(:hints)

      Result.prepend(ResultExtensions)
    end
  end
end
