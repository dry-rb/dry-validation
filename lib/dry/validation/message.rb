require 'dry/validation/constants'

module Dry
  module Validation
    class Message
      include Dry::Equalizer(:predicate, :path, :text, :options)

      Index = Class.new {
        def inspect
          "index"
        end
        alias_method :to_s, :inspect
      }.new

      attr_reader :predicate, :path, :text, :rule, :args, :options

      class Or
        attr_reader :left

        attr_reader :right

        attr_reader :path

        attr_reader :messages

        def initialize(left, right, messages)
          @left = left
          @right = right
          @messages = messages
          @path = left.path
        end

        def hint?
          false
        end

        def root?
          path.empty?
        end

        def index_path
          left.index_path
        end

        def to_s
          [left, right].uniq.join(" #{messages[:or]} ")
        end
      end

      class Each < Message
        def index_path
          @index_path ||= [*path[0..path.size-2], Index]
        end

        def each?
          true
        end
      end

      class Check < Message
        def initialize(*args)
          super
          @path = [rule] unless rule.to_s.end_with?('?') || path.include?(rule)
        end

        def each?
          false
        end
      end

      def self.[](predicate, path, text, options)
        if options[:check]
          Message::Check.new(predicate, path, text, options)
        else
          klass = options[:each] ? Message::Each : Message
          klass.new(predicate, path, text, options)
        end
      end

      def initialize(predicate, path, text, options)
        @predicate = predicate
        @path = path
        @text = text
        @options = options
        @rule = options[:rule]
        @each = options[:each] || false
        @args = options[:args] || EMPTY_ARRAY

        if predicate == :key?
          @path << rule
        end
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
