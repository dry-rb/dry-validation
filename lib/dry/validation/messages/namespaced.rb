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
      end
    end
  end
end
