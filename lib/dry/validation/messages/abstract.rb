require 'thread_safe/cache'

module Dry
  module Validation
    module Messages
      class Abstract
        extend Dry::Configurable

        setting :root, 'errors'.freeze

        setting :lookup_options, [:root, :predicate, :rule, :arg_type].freeze

        setting :lookup_paths, %w(
          %{root}.%{rule}.%{predicate}.%{arg_type}
          %{root}.%{rule}.%{predicate}
          %{root}.%{predicate}.%{arg_type}
          %{root}.%{predicate}
        ).freeze

        setting :arg_type_default, 'default'.freeze

        setting :arg_types, Hash.new { |*| config.arg_type_default }.update(
          Range => 'range'
        )

        def call(*args)
          cache.fetch_or_store(args.hash) { get(*lookup(*args)) }
        end
        alias_method :[], :call

        def lookup(predicate, options)
          tokens = options.merge(
            root: root,
            predicate: predicate,
            arg_type: config.arg_types[options[:arg_type]]
          )

          path = lookup_paths(tokens).detect { |key| key?(key) && get(key).is_a?(String) }
          opts = options.reject { |k, _| config.lookup_options.include?(k) }

          [path, opts]
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

        def cache
          @cache ||= ThreadSafe::Cache.new
        end
      end
    end
  end
end
