# frozen_string_literal: true

require "dry/schema/path"

module Dry
  module Schema
    class Path
      # @api private
      def multi_value?
        last.is_a?(Array)
      end

      # @api private
      def expand
        to_a[0..-2].product(last).map { |spec| self.class[spec] }
      end
    end
  end
end
