module Dry
  class Validator
    # @api private
    module Support
      module_function

      def merge_rules(hash, other)
        Hash[hash].merge(other) do |_key, original_value, new_value|
          if original_value.is_a?(::Hash) && new_value.is_a?(::Hash)
            merge_rules(Hash[original_value], Hash[new_value])
          else
            new_value
          end
        end
      end
    end
  end
end
