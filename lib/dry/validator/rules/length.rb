module Dry
  class Validator
    module Rules
      # Length rule, for validating string length
      #
      # @example
      #
      #   Dry::Validator::Rules::Length.call(
      #     '',
      #     { min: 3, max: 10 }
      #   )
      #     => {:code=>"length", :options=>{:min=>3, :max=>10}}
      #
      #   Dry::Validator::Rules::Length.call(
      #     '',
      #     3..10
      #   )
      #     => {:code=>"length", :value=>"", :options=>{:min=>3, :max=>10}}
      #
      # @api public
      module Length
        module_function
        # Validate the value
        #
        # @param [Mixed] value
        # @param [Hash|Range] options
        # @option options [Integer] :min The minimum length
        # @option options [Integer] :max The maximum length
        #
        # @return [Hash|NilClass]
        #
        # @api public
        def call(value, options = {}, _validator = nil)
          if options.is_a?(::Range)
            options = {
              min: options.min,
              max: options.max
            }
          end

          min = options.fetch(:min, -Float::INFINITY)
          max = options.fetch(:max, Float::INFINITY)

          {
            code: 'length',
            value: value,
            options: options
          } unless value.respond_to?(:length) && (min..max).include?(value.length)
        end
      end
    end
  end
end
