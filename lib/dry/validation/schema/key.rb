require 'dry/validation/schema/attr'
require 'dry/validation/schema/rule'

module Dry
  module Validation
    class Schema
      class Key < BasicObject
        attr_reader :name

        def initialize(name)
          @name = name
        end

        def class
          Key
        end

        private

        def create_rule(node)
          Schema::Rule.new(node, target: self, name: name)
        end

        def method_missing(meth, *args, &block)
          predicate = [:predicate, [meth, args]]

          if block
            result = yield(Value.new(name))
            create_rule([:key, [name, [:and, [[:val, predicate], result.to_ast]]]])
          else
            create_rule([:key, [name, predicate]])
          end
        end
      end
    end
  end
end
