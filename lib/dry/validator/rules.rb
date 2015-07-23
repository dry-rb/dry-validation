require 'dry/validator/rules/registry'
require 'dry/validator/rules/each'
require 'dry/validator/rules/embedded'
require 'dry/validator/rules/length'
require 'dry/validator/rules/presence'

module Dry
  class Validator
    # Validation rules
    #
    # @example
    #
    #   Dry::Validator::Rules.register :presence, ->(value, options, _validator = nil) do
    #     result = {
    #       code: 'presence',
    #       options: options
    #     }
    #     result if (options && value.to_s.length == 0) || (!options && value.to_s.length > 0)
    #   end
    #
    #   Dry::Validator::Rules[:presence].call('', true)
    #     => {:code=>"presence", :value=>"", :options=>true}
    #
    # @api public
    module Rules
      extend ::Dry::Container::Mixin

      configure do |config|
        config.registry = Registry.new
      end

      register(:each, Each)
      register(:embedded, Embedded)
      register(:length, Length)
      register(:presence, Presence)
    end
  end
end
