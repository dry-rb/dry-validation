module Dry
  module Validation
    module Messages
      class Namespaced < Messages::Abstract
        attr_reader :namespace, :messages, :root

        def initialize(namespace, messages)
          super()
          @namespace = namespace
          @messages = messages
          @root = messages.root
        end

        def key?(key, *args)
          messages.key?(key, *args)
        end

        def get(key, options = {})
          messages.get(key, options)
        end

        def lookup_paths(tokens)
          super(tokens.merge(root: "#{root}.rules.#{namespace}")) + super
        end

        def default_locale
          messages.default_locale
        end

        def rule_path(name)
          path_parts = messages.rule_path(name).split('.')
          [
              path_parts[0, path_parts.size - 1],
              namespace,
              path_parts.last
          ].join('.')
        end
      end
    end
  end
end
