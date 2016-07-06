require 'dry/validation/constants'

module Dry
  module Validation
    class Message < Struct.new(:predicate, :path, :text, :options)
      Index = Class.new {
        def inspect
          "index"
        end
        alias_method :to_s, :inspect
      }.new

      attr_reader :rule, :args

      class Each < Message
        def index_path
          @index_path ||= [*path[0..path.size-2], Index]
        end

        def each?
          true
        end
      end

      def self.[](predicate, path, text, options)
        klass = options[:each] ? Message::Each : Message
        klass.new(predicate, path, text, options)
      end

      def initialize(*args)
        super
        @rule = options[:rule]
        @each = options[:each] || false
        @args = options[:args] || EMPTY_ARRAY
      end

      alias_method :index_path, :path

      def to_s
        text
      end

      def signature
        @signature ||= [predicate, args, index_path].hash
      end

      def each?
        @each
      end

      def hint?
        false
      end

      def root?
        path.empty?
      end

      def eql?(other)
        other.is_a?(String) ? text == other : super
      end
    end

    class Hint < Message
      def self.[](predicate, path, text, options)
        klass = options[:each] ? Hint::Each : Hint
        klass.new(predicate, path, text, options)
      end

      class Each < Hint
        def index_path
          @index_path ||= [*path, Index]
        end
      end

      def hint?
        true
      end
    end
  end
end
