require 'dry/validation/schema/sourced'

module Dry
  module Validation
    class Schema
      class Rule < BasicObject
        attr_reader :name, :node, :type, :target, :keys, :options

        def initialize(node, options = {})
          @node = node
          @target = options.fetch(:target)
          @keys = options.fetch(:keys, [name])
          @type = options.fetch(:type, :and)
          @options = options
          @name = options[:name]
        end

        def add_rule(rule)
          target.add_rule(rule)
        end

        def rules
          target.rules
        end

        def to_ast
          node
        end

        def class
          Schema::Rule
        end

        def to_implication
          with(type: :then)
        end

        def required(*predicates)
          rule = ([key(:filled?)] + infer_predicates(predicates)).reduce(:and)

          add_rule(__send__(type, rule))
        end

        def maybe(*predicates)
          rule =
            if predicates.size > 0
              key(:none?).or(infer_predicates(predicates).reduce(:and))
            else
              key(:none?).or(key(:filled?))
            end

          add_rule(__send__(type, rule))
        end

        def when(*predicates, &block)
          left = ::Kernel.Array(predicates).map { |predicate|
            target.value(name).__send__(*::Kernel.Array(predicate))
          }.reduce(:and)

          Rule::Result.with_current_rule(left, &block)
        end

        def confirmation
          conf = :"#{name}_confirmation"

          key = Value.new(conf).key(conf).maybe
          val = key.value(conf)

          result = self.when(:filled?) { val.eql?(value(name)) }

          rules.concat(val.rules)
          checks.concat(val.checks)

          result
        end

        def not
          new([:not, node])
        end

        def and(other)
          new_from([:and, [node, other.node]], other)
        end
        alias_method :&, :and

        def or(other)
          new_from([:or, [node, other.node]], other)
        end
        alias_method :|, :or

        def xor(other)
          new_from([:xor, [node, other.node]], other)
        end
        alias_method :^, :xor

        def then(other)
          new_from([:implication, [node, other.node]], other)
        end
        alias_method :>, :then

        def with(new_options)
          self.class.new(name, node, options.merge(new_options))
        end

        private

        def infer_predicates(predicates)
          predicates.map do |predicate|
            name, args = ::Kernel.Array(predicate).flatten
            key(name, ::Kernel.Array(args))
          end
        end

        def key(predicate, args = [])
          new([:key, [name, [:predicate, [predicate, args]]]])
        end

        def new_from(node, other)
          self.class.new(node, options.merge(target: target, keys: (keys + other.keys).uniq))
        end

        def new(node, name = self.name)
          self.class.new(node, options.merge(name: name))
        end
      end
    end
  end
end
