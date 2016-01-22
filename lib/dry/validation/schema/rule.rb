module Dry
  module Validation
    class Schema
      class Rule < BasicObject
        attr_reader :name, :node, :target

        class Check < Rule
          def class
            Schema::Rule::Check
          end

          private

          def method_missing(meth, *)
            new([:check, [name, [:predicate, [name, [meth]]]]])
          end
        end

        class Result < Rule
          def class
            Schema::Rule::Result
          end

          def rename(name)
            new(node, name)
          end

          private

          def method_missing(meth, *args)
            new([:res, [name, [:predicate, [meth, args]]]])
          end
        end

        def initialize(name, node, target)
          @name = name
          @node = node
          @target = target
        end

        def class
          Schema::Rule
        end

        def to_ary
          node
        end
        alias_method :to_a, :to_ary

        def to_check
          Rule::Check.new(name, [:check, [name, [:predicate, [name, []]]]], target)
        end

        def is_a?(other)
          self.class == other
        end

        def required(*predicates)
          rule = ([val(:filled?)] + infer_predicates(predicates)).reduce(:and)

          target.rules << self.and(rule)
          target.rules.last
        end

        def maybe
          target.rules << self.and(val(:none?).or(val(:filled?)))
          target.rules.last
        end

        def when(predicate, rule_name = nil, &block)
          left = target.value(name).__send__(predicate)
          right = yield

          target.rule(rule_name || right.name) { left.then(right) }

          target.checks.last
        end

        def not
          new([:not, node])
        end

        def and(other)
          new([:and, [node, other.to_ary]])
        end
        alias_method :&, :and

        def or(other)
          new([:or, [node, other.to_ary]])
        end
        alias_method :|, :or

        def xor(other)
          new([:xor, [node, other.to_ary]])
        end
        alias_method :^, :xor

        def then(other)
          new([:implication, [node, other.to_ary]])
        end
        alias_method :>, :then

        private

        def infer_predicates(predicates)
          predicates.map do |predicate|
            name, args = ::Kernel.Array(predicate).flatten
            val(name, ::Kernel.Array(args))
          end
        end

        def val(predicate, args = [])
          new([:val, [name, [:predicate, [predicate, args]]]])
        end

        def new(node, name = self.name)
          self.class.new(name, node, target)
        end
      end
    end
  end
end
