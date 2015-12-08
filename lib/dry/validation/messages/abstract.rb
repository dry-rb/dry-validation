require 'pathname'
require 'thread_safe/cache'

module Dry
  module Validation
    module Messages
      class Abstract
        DEFAULT_PATH = Pathname(__dir__).join('../../../../config/errors.yml').realpath.freeze

        extend Dry::Configurable

        setting :paths, [DEFAULT_PATH]
        setting :root, 'errors'.freeze
        setting :lookup_options, [:root, :predicate, :rule, :val_type, :arg_type].freeze

        setting :lookup_paths, %w(
          %{root}.rules.%{rule}.%{predicate}.arg.%{arg_type}
          %{root}.rules.%{rule}.%{predicate}
          %{root}.%{predicate}.value.%{val_type}.arg.%{arg_type}
          %{root}.%{predicate}.value.%{val_type}
          %{root}.%{predicate}.arg.%{arg_type}
          %{root}.%{predicate}
        ).freeze

        setting :arg_type_default, 'default'.freeze
        setting :val_type_default, 'default'.freeze

        setting :arg_types, Hash.new { |*| config.arg_type_default }.update(
          Range => 'range'
        )

        setting :val_types, Hash.new { |*| config.val_type_default }.update(
          Range => 'range',
          String => 'string'
        )

        def call(*args)
          cache.fetch_or_store(args.hash) { get(*lookup(*args)) }
        end
        alias_method :[], :call

        def lookup(predicate, options)
          tokens = options.merge(
            root: root,
            predicate: predicate,
            arg_type: config.arg_types[options[:arg_type]],
            val_type: config.val_types[options[:val_type]]
          )

          opts = options.reject { |k, _| config.lookup_options.include?(k) }
          path = lookup_paths(tokens).detect { |key| key?(key, opts) && get(key).is_a?(String) }

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
