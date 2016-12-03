require 'yaml'
require 'pathname'

require 'dry/equalizer'
require 'dry/validation/messages/abstract'

module Dry
  module Validation
    class Messages::YAML < Messages::Abstract
      include Dry::Equalizer(:data)

      attr_reader :data

      configure do |config|
        config.root = '%{locale}.errors'.freeze
      end

      def self.load(paths = config.paths)
        new(paths.map { |path| load_file(path) }.reduce(:merge))
      end

      def self.load_file(path)
        flat_hash(YAML.load_file(path))
      end

      def self.flat_hash(h, f = [], g = {})
        return g.update(f.join('.'.freeze) => h) unless h.is_a? Hash
        h.each { |k, r| flat_hash(r, f + [k], g) }
        g
      end

      def initialize(data)
        super()
        @data = data
      end

      def get(key, options = {})
        data[key % { locale: options.fetch(:locale, default_locale) }]
      end

      def key?(key, options = {})
        data.key?(key % { locale: options.fetch(:locale, default_locale) })
      end

      def merge(overrides)
        if overrides.is_a?(Hash)
          self.class.new(data.merge(self.class.flat_hash(overrides)))
        else
          self.class.new(data.merge(Messages::YAML.load_file(overrides)))
        end
      end
    end
  end
end
