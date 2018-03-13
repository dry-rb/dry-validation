require 'dry/equalizer'

module Dry
  module Validation
    class Message
      include Dry::Equalizer(:predicate, :path, :text, :options)

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

        def to_s
          [left, right].uniq.join(" #{messages[:or]} ")
        end
      end

      def self.[](predicate, path, text, options)
        Message.new(predicate, path, text, options)
      end

      def initialize(predicate, path, text, options)
        @predicate = predicate
        @path = path
        @text = text
        @options = options
        @rule = options[:rule]
        @args = options[:args] || EMPTY_ARRAY

        if predicate == :key?
          @path << rule
        end
      end

      def to_s
        text
      end

      def signature
        @signature ||= [predicate, args, path].hash
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
        Hint.new(predicate, path, text, options)
      end

      def hint?
        true
      end
    end
  end
end
