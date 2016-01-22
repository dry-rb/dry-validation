module Dry
  module Validation
    class Schema
      class Rule# < BasicObject
        attr_reader :name, :node, :target

        class Check < Rule
          def class
            Schema::Rule::Check
          end

          def method_missing(meth, *)
            new([:check, [name, [:predicate, [name, [meth]]]]])
          end
        end

        class Result < Rule
          def class
            Schema::Rule::Result
          end

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

        def new(node, name = self.name)
          self.class.new(name, node, target)
        end

        def is_a?(other)
          self.class == other
        end

        def required
          filled = new([:val, [name, [:predicate, [:filled?, []]]]])

          target.rules << self.and(filled)
          target.rules.last
        end

        def maybe
          filled = new([:val, [name, [:predicate, [:filled?, []]]]])
          none = new([:val, [name, [:predicate, [:none?, []]]]])

          target.rules << self.and(none.or(filled))
          target.rules.last
        end

        def on(predicate, &block)
          left = target.value(name).__send__(predicate)
          right = yield

          target.checks << left.then(right)
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
      end
    end
  end
end
