require 'dry-equalizer'
require 'dry-configurable'
require 'dry-container'

# A collection of micro-libraries, each intended to encapsulate
# a common task in Ruby
module Dry
  module Validation
  end
end

require 'dry/validation/predicate'
require 'dry/validation/schema'
require 'dry/validation/predicate_set/built_in'
