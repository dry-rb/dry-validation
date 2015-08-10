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
      #     => {
      #          :code=>"each",
      #          :errors=>[{}, {:name=>[{:code=>"presence", :value=>"", :options=>true}]}],
      #          :value=>[{:name=>"Jack"}, {:name=>""}],
      #          :options=>{:name=>{:presence=>true}}
      #        }
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
        def call(value, rules = {}, validator = nil)
          if rules.respond_to?(:call)
            validator = rules
          else
            validator = validator.class.new(
              rules: rules,
              processor: validator.processor
            )
          end

          errors = value.map { |object| validator.call(object) }

          {
            code: 'each',
            errors: errors,
            value: value,
            options: validator.rules
          } unless errors.all?(&:empty?)
        end
      end
    end
  end
end
