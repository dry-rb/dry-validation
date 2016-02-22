require 'dry/validation/schema/rule'

module Dry
  module Validation
    class Schema
      class DSL < BasicObject
        attr_reader :name, :rules, :options

        def self.[](name)
          new(name: name)
        end

        def initialize(options = {})
          @name = options[:name]
          @rules = options.fetch(:rules, [])
          @options = options
        end

        def key(name, &block)
          if block
            val = Value[name].key?(name)
            res = Key[name].instance_eval(&block)

            if res.class == Value
              add_rule(val.and(create_rule([:key, [name, res.to_ast]])))
            else
              add_rule(val.and(create_rule(res.to_ast)))
            end
          else
            named(name).key?(name)
          end
        end

        def named(name)
          Value.new(name: name, rules: rules)
        end

        def not
          negated = create_rule([:not, to_ast])
          @rules = [negated]
          self
        end

        def add_rule(rule)
          rules << rule
          self
        end

        private

        def create_rule(node)
          Schema::Rule.new(node, name: name, target: self)
        end
      end
    end
  end
end
