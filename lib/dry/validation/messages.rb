require 'yaml'

module Dry
  module Validation
    class Messages
      DEFAULT_PATH = Pathname(__dir__).join('../../../config/errors.yml').freeze

      attr_reader :data

      def self.default
        load(DEFAULT_PATH)
      end

      def self.load(path)
        new(load_yaml(path))
      end

      def self.load_yaml(path)
        symbolize_keys(YAML.load_file(path))
      end

      def self.symbolize_keys(hash)
        hash.each_with_object({}) do |(k, v), r|
          r[k.to_sym] = v.is_a?(Hash) ? symbolize_keys(v) : v
        end
      end

      class Namespaced
        attr_reader :namespace, :fallback

        def initialize(namespace, fallback)
          @namespace = namespace
          @fallback = fallback
        end

        def lookup(*args)
          namespace.lookup(*args) { fallback.lookup(*args) }
        end
      end

      def initialize(data)
        @data = data
      end

      def merge(overrides)
        if overrides.is_a?(Hash)
          self.class.new(data.merge(overrides))
        else
          self.class.new(data.merge(Messages.load_yaml(overrides)))
        end
      end

      def namespaced(namespace)
        Namespaced.new(Messages.new(data[namespace]), self)
      end

      def lookup(identifier, key, &block)
        data.fetch(:attributes, {}).fetch(key, {}).fetch(identifier) do
          data.fetch(identifier, &block)
        end
      end
    end
  end
end
