module Dry
  module Validation
    class Schema
      module Definition
        class Rule
          attr_reader :node

          def initialize(node)
            @node = node
          end

          def to_ary
            node
          end
          alias_method :to_a, :to_ary

          def &(other)
            self.class.new([:and, [node, other.to_ary]])
          end

          def |(other)
            self.class.new([:or, [node, other.to_ary]])
          end
        end
      end
    end
  end
end
