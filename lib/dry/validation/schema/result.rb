module Dry
  module Validation
    class Schema::Result
      include Dry::Equalizer(:params, :errors)
      include Enumerable

      attr_reader :params

      attr_reader :errors

      def initialize(params, errors)
        @params = params
        @errors = errors
      end

      def each(&block)
        errors.each(&block)
      end

      def empty?
        errors.empty?
      end

      def to_ary
        errors.map(&:to_ary)
      end
    end
  end
end
