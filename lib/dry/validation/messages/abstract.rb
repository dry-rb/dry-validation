module Dry
  module Validation
    module Messages
      class Abstract
        extend Dry::Configurable

        setting :root, 'errors'

        setting :lookup_paths, %w(
          %{root}.%{rule}.%{predicate}.%{predicate_arg_type}
          %{root}.%{rule}.%{predicate}
          %{root}.%{predicate}.%{predicate_arg_type}
          %{root}.%{predicate}
        )

        def call(*args)
          get(lookup(*args))
        end
        alias_method :[], :call

        def lookup(predicate, rule, predicate_arg = nil, &block)
          tokens = {
            root: root,
            rule: rule,
            predicate: predicate,
            predicate_arg_type: predicate_arg.class.name.downcase.to_sym
          }

          path = lookup_paths(tokens).detect { |key| key?(key) && get(key).is_a?(String) }

          if path
            path
          elsif block
            yield
          end
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
