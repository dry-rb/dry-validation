require 'dry/validation/rules/registry'
require 'dry/validation/rules/each'
require 'dry/validation/rules/embedded'
require 'dry/validation/rules/exclusion'
require 'dry/validation/rules/inclusion'
require 'dry/validation/rules/length'
require 'dry/validation/rules/presence'

module Dry
  module Validation
    module Rules
      extend ::Dry::Container::Mixin

      configure do |config|
        config.registry = Registry.new
      end

      register(:each, Each)
      register(:embedded, Embedded)
      register(:exclusion, Exclusion)
      register(:inclusion, Inclusion)
      register(:length, Length)
      register(:presence, Presence)
    end
  end
end
