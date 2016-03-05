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

        def path
          items = [parent && parent.path, name].flatten.compact.uniq
          items.size == 1 ? items[0] : items
        end

        def key(name, &block)
          val = Value[name, type: :key, parent: self, checks: checks, rules: rules].key?(name)

          if block
            key = Key[name]
            res = key.instance_eval(&block)

            if res.class == Value
              checks.concat(key.checks)
              add_rule(val.and(create_rule([:key, [name, res.to_ast]])))
            else
              add_rule(val.and(create_rule(res.to_ast)))
            end
          else
            val
          end
        end

        def attr(name, &block)
          val = Value[name, type: :attr, parent: self, rules: rules].attr?(name)

          if block
            res = Attr[name].instance_eval(&block)

            if res.class == Value
              add_rule(val.and(create_rule([:attr, [name, res.to_ast]])))
            else
              add_rule(val.and(create_rule(res.to_ast)))
            end
          else
            val
          end
        end

        def optional(name, &block)
          val = Value[name, type: :key, parent: self, checks: checks, rules: rules].key?(name)

          if block
            res = Key[name].instance_eval(&block)

            if res.class == Value
              checks.concat(res.checks)
              add_rule(val.then(create_rule([:key, [name, res.to_ast]])))
            else
              add_rule(val.then(create_rule(res.to_ast)))
            end
          else
            val.to_implication
          end
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

        private

        def create_rule(node)
          Schema::Rule.new(node, name: name, path: path, target: self)
        end
      end
    end
  end
end
