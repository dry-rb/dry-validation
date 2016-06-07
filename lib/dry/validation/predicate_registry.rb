module Dry
  module Logic
    # FIXME: move dis to dry-logic
    class Predicate
      def arity
        fn.arity
      end
    end
  end

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
            raise_unknown_predicate_error(name)
          end
        end
      end

      def key?(name)
        predicates.key?(name) || external.key?(name)
      end

      def ensure_valid_predicate(name, args)
        if key?(name)
          predicate = self[name]

          if predicate.arity != args.size + 1
            raise_invalid_arity_error(name)
          end
        else
          raise_unknown_predicate_error(name)
        end
      end

      private

      def raise_unknown_predicate_error(name)
        raise ArgumentError, "+#{name}+ is not a valid predicate name"
      end

      def raise_invalid_arity_error(name)
        raise ArgumentError, "#{name} predicate arity is invalid"
      end
    end
  end
end
