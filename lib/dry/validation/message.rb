module Dry
  module Validation
    Message = Struct.new(:rule, :predicate, :path, :text) do
      def to_s
        text
      end

      def root?
        path.empty?
      end

      def hint?
        @hint == true
      end

      def each?
        @each == true
      end

      def to_h
        @to_h ||= [[self], *path.reverse].reduce { |a, e| { e => a } }
      end

      def signature
        @signature ||= [rule, predicate].hash
      end

      def hint!(each = false)
        @hint = true
        @each = each
      end

      def eql?(other)
        other.is_a?(String) ? text == other : super
      end

      def empty?
        false
      end
    end
  end
end
