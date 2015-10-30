module Dry
  module Validation
    # @api private
    module Support
      module_function

      def deep_merge!(hash, other)
        hash.merge!(other) do |_key, original_value, new_value|
          if original_value.is_a?(::Hash) && new_value.is_a?(::Hash)
            deep_merge!(original_value, new_value)
          else
            new_value
          end
        end
      end
    end
  end
end
