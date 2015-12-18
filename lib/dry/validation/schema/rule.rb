module Dry
  module Validation
    class Schema
      class Rule
        attr_reader :name, :node

        class Generic < Rule
        end

        def initialize(name, node)
          @name = name
          @node = node
        end

        def to_ary
          node
        end
        alias_method :to_a, :to_ary

        def to_generic
          Rule::Generic.new(name, [:rule, [name, [:predicate, [name, []]]]])
        end

        def and(other)
          self.class.new(:"#{name}_and_#{other.name}", [:and, [node, other.to_ary]])
        end
        alias_method :&, :and

        def or(other)
          self.class.new(:"#{name}_or_#{other.name}", [:or, [node, other.to_ary]])
        end
        alias_method :|, :or

        def then(other)
          self.class.new(:"#{name}_then_#{other.name}", [:implication, [node, other.to_ary]])
        end
        alias_method :>, :then
      end
    end
  end
end
