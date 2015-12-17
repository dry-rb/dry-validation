module Dry
  module Validation
    class Schema
      class Rule
        attr_reader :name, :node

        def initialize(node)
          @node = node
        end

        def to_ary
          node
        end
        alias_method :to_a, :to_ary

        def and(other)
          self.class.new([:and, [node, other.to_ary]])
        end
        alias_method :&, :and

        def or(other)
          self.class.new([:or, [node, other.to_ary]])
        end
        alias_method :|, :or

        def then(other)
          self.class.new([:implication, [node, other.to_ary]])
        end
        alias_method :>, :then
      end
    end
  end
end
