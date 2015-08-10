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
      #     => {
      #          :code=>"embedded",
      #          :errors=>{
      #            :name=>[{:code=>"presence", :value=>"", :options=>true}]
      #          },
      #          :value=>{:name=>""},
      #          :options=>{:name=>{:presence=>true}}
      #        }
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
        def call(value, rules = {}, validator = nil)
          if rules.respond_to?(:call)
            validator = rules
          else
            validator = validator.class.new(
              rules: rules,
              processor: validator.processor
            )
          end

          errors = validator.call(value)

          {
            code: 'embedded',
            errors: errors,
            value: value,
            options: validator.rules
          } if errors.any?
        end
      end
    end
  end
end
