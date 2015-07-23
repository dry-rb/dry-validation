module Dry
  class Validator
    module Rules
      # Exclusion rule, for validating exclusion
      #
      # @example
      #
      #   Dry::Validator::Rules::Exclusion.call(true, [true, false])
      #     => {:code=>"exclusion", :value=>true, :options=>[true, false]}
      #
      # @api public
      module Exclusion
        module_function
        # Validate the value
        #
        # @param [Mixed] value
        # @param [Enumerable] values The array of values to validate exclusion from
        #
        # @return [Hash|NilClass]
        #
        # @api public
        def call(value, values = [], _validator = nil)
          { code: 'exclusion', value: value, options: values } if values.include?(value)
        end
      end
    end
  end
end
