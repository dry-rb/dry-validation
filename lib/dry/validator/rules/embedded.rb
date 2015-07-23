module Dry
  class Validator
    module Rules
      # Embedded rule, for validating embedded structures
      #
      # @example
      #
      #   validator = Dry::Validator.new(name: { presence: true })
      #
      #   Dry::Validator::Rules::Embedded.call(
      #     { name: '' },
      #     validator.rules,
      #     validator
      #   )
      #     => {:name=>[{:code=>"presence", :options=>true}]}
      #
      # @api public
      module Embedded
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

          validator.call(value)
        end
      end
    end
  end
end
