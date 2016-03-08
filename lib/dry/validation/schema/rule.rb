module Dry
  module Validation
    class Schema
      class Rule < BasicObject
        attr_reader :name, :node, :type, :target, :options

        def initialize(node, options = {})
          @node = node
          @name = options.fetch(:name)
          @target = options.fetch(:target)
          @type = options.fetch(:type, :and)
          @options = options
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

        def add_rule(rule)
          target.add_rule(rule)
        end

        def rules
          target.rules
        end

        def checks
          target.checks
        end

        def to_ast
          node
        end

        def class
          Schema::Rule
        end

        def not
          new([:not, node])
        end

        def and(other)
          new([:and, [node, other.to_ast]])
        end
        alias_method :&, :and

        def or(other)
          new([:or, [node, other.to_ast]])
        end
        alias_method :|, :or

        def xor(other)
          new([:xor, [node, other.to_ast]])
        end
        alias_method :^, :xor

        def then(other)
          new([:implication, [node, other.to_ast]])
        end
        alias_method :>, :then

        def infer_predicates(predicates)
          predicates.map do |predicate|
            name, args = ::Kernel.Array(predicate).flatten
            key(name, ::Kernel.Array(args))
          end
        end

        def with(new_options)
          self.class.new(node, options.merge(new_options))
        end

        private

        def key(predicate, args = [])
          new([target.type, [name, [:predicate, [predicate, args]]]])
        end

        def new(node)
          self.class.new(node, options)
        end
      end
    end
  end
end
