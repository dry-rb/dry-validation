require 'dry-equalizer'
require 'dry-configurable'
require 'dry-container'

# A collection of micro-libraries, each intended to encapsulate
# a common task in Ruby
module Dry
  module Validation
    def self.symbolize_keys(hash)
      hash.each_with_object({}) do |(k, v), r|
        r[k.to_sym] = v.is_a?(Hash) ? symbolize_keys(v) : v
      end
    end
  end
end

require 'dry/validation/schema'
