require 'dry/validation/schema'
require 'dry/validation/schema/attr'

module Dry
  module Validation
    class Model < Schema
      def self.attr(name, &block)
        rules[name] = Value.new(type: :attr).attr(name, &block)
      end
    end
  end
end
