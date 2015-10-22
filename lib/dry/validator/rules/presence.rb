module Dry
  class Validator
    module Rules
      # Presence rule, for validating presence
      #
      # @example
      #
      #   Dry::Validator::Rules::Presence.call('', true)
      #     => {:code=>"presence", :options=>true}
      #
      #   Dry::Validator::Rules::Presence.call('Jack', false)
      #     => {:code=>"presence", :value=>"Jack", :options=>false}
      #
      # @api public
      module Presence
        module_function
        # Validate the value
        #
        # @param [Mixed] value
        # @param [Boolean] switch
        #
        # @return [Hash|NilClass]
        #
        # @api public
        def call(value, switch = true, _validator = nil)
          {
            code: 'presence',
            value: value,
            options: switch
          } if (switch == (value.respond_to?(:length) && value.length == 0))
        end
      end
    end
  end
end
