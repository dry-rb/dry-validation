require 'yaml'

module Dry
  module Validation
    def self.Messages(overrides = {})
      messages = Messages.load

      if overrides.any?
        messages.merge(overrides)
      else
        messages
      end
    end

    class Messages
      DEFAULT_PATH = Pathname(__dir__).join('../../../config/errors.yml').freeze

      attr_reader :data

      def self.load(path = DEFAULT_PATH)
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

      def initialize(data)
        @data = data
      end

      def merge(overrides)
        self.class.new(data.merge(overrides))
      end

      def lookup(identifier, key)
        data.fetch(:attributes, {}).fetch(key, {}).fetch(identifier) do
          data.fetch(identifier)
        end
      end
    end
  end
end
