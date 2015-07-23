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
      #     => {:code=>"presence", :options=>false}
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
          result = {
            code: 'presence',
            options: switch
          }
          result if (switch && value.to_s.length == 0) || (!switch && value.to_s.length > 0)
        end
      end
    end
  end
end
