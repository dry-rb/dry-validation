require 'dry/validation/schema/rule'

module Dry
  module Validation
    class Schema
      class DSL < BasicObject
        attr_reader :name, :rules, :checks, :parent, :options

        def self.[](name, options = {})
          new(options.merge(name: name))
        end

        def initialize(options = {})
          @name = options[:name]
          @parent = options[:parent]
          @rules = options.fetch(:rules, [])
          @checks = options.fetch(:checks, [])
          @options = options
        end

        def inspect
          to_ast.inspect
        end
        alias_method :to_s, :inspect

        def optional(name, &block)
          define(name, Key, :then, &block)
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

        def add_check(check)
          checks << check
          self
        end

        def to_ast
          ast = rules.map(&:to_ast)
          ast.size > 1 ? [:set, ast] : ast[0] || []
        end

        def to_rule
          create_rule(to_ast)
        end

        def rule_ast
          rules.map(&:to_ast)
        end

        def path
          items = [parent && parent.path, name].flatten.compact.uniq
          items.size == 1 ? items[0] : items
        end

        def with(new_options)
          self.class.new(options.merge(new_options))
        end

        private

        def define(name, key_class, op = :and, &block)
          type = key_class.type

          val = Value[
            name, type: type, parent: self, rules: rules, checks: checks
          ].__send__(:"#{type}?", name)

          if block
            key = key_class[name]
            res = key.instance_eval(&block)

            if res.class == Value
              checks.concat(key.checks)
              add_rule(val.__send__(op, create_rule([type, [name, res.to_ast]])))
            else
              add_rule(val.__send__(op, create_rule(res.to_ast)))
            end
          else
            val.with(type: op)
          end
        end

        def create_rule(node)
          Schema::Rule.new(node, name: name, target: self)
        end
      end
    end
  end
end
