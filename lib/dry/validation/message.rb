require 'dry/validation/constants'

module Dry
  module Validation
    class Message < Struct.new(:predicate, :path, :text, :options)
      attr_reader :rule, :args

      class Each < Message
        def hint_path
          @hint_path ||= path[0..path.size-2]
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

      alias_method :hint_path, :path

      def to_s
        text
      end

      def signature
        @signature ||= [predicate, args, hint_path].hash
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
        def add?(message)
          message.each? && path == message.hint_path
        end
      end

      def hint?
        true
      end

      def add?(message)
        path == message.path
      end
    end
  end
end
