module Dry
  module Validation
    module Messages
      class Abstract
        extend Dry::Configurable

        setting :root, 'errors'.freeze

        setting :lookup_paths, %w(
          %{root}.%{rule}.%{predicate}.%{predicate_arg_type}
          %{root}.%{rule}.%{predicate}
          %{root}.%{predicate}.%{predicate_arg_type}
          %{root}.%{predicate}
        ).freeze

        setting :predicate_arg_default, 'default'.freeze

        setting :predicate_arg_types, Hash.new { |*| config.predicate_arg_default }.update(
          Range => 'range'
        )

        def call(*args)
          get(lookup(*args))
        end
        alias_method :[], :call

        def lookup(predicate, rule, predicate_arg_class = NilClass)
          tokens = {
            root: root,
            rule: rule,
            predicate: predicate,
            predicate_arg_type: config.predicate_arg_types[predicate_arg_class]
          }

          lookup_paths(tokens).detect { |key| key?(key) && get(key).is_a?(String) }
        end

        def lookup_paths(tokens)
          config.lookup_paths.map { |path| path % tokens }
        end

        def namespaced(namespace)
          Messages::Namespaced.new(namespace, self)
        end

        def root
          config.root
        end

        def config
          self.class.config
        end
      end
    end
  end
end
