module Dry
  module Validation
    Message = Struct.new(:predicate, :path, :text, :options) do
      attr_reader :rule, :args

      EMPTY_ARGS = [].freeze

      def initialize(*args)
        super
        @rule = options[:rule]
        @args = options[:args] || EMPTY_ARGS
        @each = options[:each] || false
      end

      def hint_path
        @sig_path ||= each? ? path[0..path.size-2] : path
      end

      def signature
        @signature ||= [predicate, args, hint_path].hash
      end

      def hint?
        false
      end

      def to_s
        text
      end

      def root?
        path.empty?
      end

      def each?
        @each
      end

      def hint(new_opts)
        Hint.new(predicate, path, text, options.merge(new_opts))
      end

      def eql?(other)
        other.is_a?(String) ? text == other : super
      end

      def empty?
        false
      end
    end

    class Hint < Message
      def hint?
        true
      end

      def add?(message)
        if each? && message.each?
          path == message.hint_path
        else
          !each? && path == message.path
        end
      end
    end
  end
end
