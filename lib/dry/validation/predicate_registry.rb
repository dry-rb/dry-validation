module Dry
  module Validation
    class PredicateRegistry
      attr_reader :predicates
      attr_reader :external

      class Bound < PredicateRegistry
        def initialize(*args)
          super
          freeze
        end
      end

      class Unbound < PredicateRegistry
        def bind(schema)
          bound_predicates = predicates.each_with_object({}) do |(n, p), res|
            res[n] = Dry::Logic::Predicate.new(n, &p.bind(schema))
          end
          Bound.new(external, bound_predicates)
        end

        def update(other)
          predicates.update(other)
        end
      end

      def self.[](klass, predicates)
        Unbound.new(predicates).tap do |registry|
          klass.class_eval do
            def self.method_added(name)
              super
              if name.to_s.end_with?('?')
                registry.update(name => instance_method(name))
              end
            end
          end
        end
      end

      def initialize(external, predicates = {})
        @external = external
        @predicates = predicates
      end

      def [](name)
        predicates.fetch(name) do
          if external.key?(name)
            external[name]
          else
            raise ArgumentError, "+#{name}+ is not a valid predicate name"
          end
        end
      end
    end
  end
end
