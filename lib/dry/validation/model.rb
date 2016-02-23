require 'dry/validation/schema'

module Dry
  module Validation
    class Model < Schema
      def self.attr(name, &block)
        val = Value[name, type: :attr]

        keys[name] = val

        if block
          val.instance_exec(&block)
          val
        else
          Rule.new(val.to_ast, name: name, target: val)
        end
      end
    end
  end
end
