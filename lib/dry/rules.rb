require 'dry/rules/registry'
require 'dry/rules/each'
require 'dry/rules/embedded'
require 'dry/rules/length'
require 'dry/rules/presence'

module Dry
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
