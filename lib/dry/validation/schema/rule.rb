module Dry
  module Validation
    class Schema
      class Rule < BasicObject
        attr_reader :name, :node

        class Check < Rule
          def class
            Schema::Rule::Check
          end

          def method_missing(meth, *)
            self.class.new(name, [:check, [name, [:predicate, [name, [meth]]]]])
          end
        end

        class Result < Rule
          def class
            Schema::Rule::Result
          end

          def method_missing(meth, *args)
            self.class.new(name, [:res, [name, [:predicate, [meth, args]]]])
          end
        end

        def initialize(name, node)
          @name = name
          @node = node
        end

        def class
          Schema::Rule
        end

        def to_ary
          node
        end
        alias_method :to_a, :to_ary

        def to_check
          Rule::Check.new(name, [:check, [name, [:predicate, [name, []]]]])
        end

        def is_a?(other)
          self.class == other
        end

        def not
          self.class.new(:"not_#{name}", [:not, node])
        end

        def and(other)
          self.class.new(:"#{name}_and_#{other.name}", [:and, [node, other.to_ary]])
        end
        alias_method :&, :and

        def or(other)
          self.class.new(:"#{name}_or_#{other.name}", [:or, [node, other.to_ary]])
        end
        alias_method :|, :or

        def xor(other)
          self.class.new(:"#{name}_xor_#{other.name}", [:xor, [node, other.to_ary]])
        end
        alias_method :^, :xor

        def then(other)
          self.class.new(:"#{name}_then_#{other.name}", [:implication, [node, other.to_ary]])
        end
        alias_method :>, :then
      end
    end
  end
end
