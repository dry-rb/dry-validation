module Dry
  class Validator
    module Rules
      # Each rule, for validating arrays
      #
      # @example
      #
      #   validator = Dry::Validator.new({ name: { presence: true } })
      #
      #   Dry::Validator::Rules::Each.call(
      #     [{ name: 'Jack' }, { name: '' }],
      #     validator.rules,
      #     validator
      #   )
      #     => [{}, {:name=>[{:code=>"presence", :options=>true}]}]
      #
      # @api public
      module Each
        module_function
        # Validate the value against rules
        #
        # @param [Mixed] value
        # @param [Hash] rules
        # @param [Mixed] validator
        #
        # @return [Hash|NilClass]
        #
        # @api public
        def call(value, rules = {}, validator)
          if rules.respond_to?(:call)
            validator = rules
          else
            validator = validator.class.new(
              rules: rules,
              processor: validator.processor
            )
          end

          value.map { |object| validator.call(object) }
        end
      end
    end
  end
end
