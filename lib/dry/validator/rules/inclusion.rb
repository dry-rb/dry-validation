module Dry
  class Validator
    module Rules
      # Inclusion rule, for validating inclusion
      #
      # @example
      #
      #   Dry::Validator::Rules::Inclusion.call(nil, [true, false])
      #     => {:code=>"inclusion", :value=>nil, :options=>[true, false]}
      #
      # @api public
      module Inclusion
        module_function
        # Validate the value
        #
        # @param [Mixed] value
        # @param [Enumerable] values The array of values to validate inclusion in
        #
        # @return [Hash|NilClass]
        #
        # @api public
        def call(value, values = [], _validator = nil)
          { code: 'inclusion', value: value, options: values } unless values.include?(value)
        end
      end
    end
  end
end
