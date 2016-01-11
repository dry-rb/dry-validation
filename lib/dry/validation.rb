require 'dry-equalizer'
require 'dry-configurable'
require 'dry-container'

# A collection of micro-libraries, each intended to encapsulate
# a common task in Ruby
module Dry
  module Validation
    def self.messages_paths
      Messages::Abstract.config.paths
    end
  end
end

require 'dry/validation/schema'
require 'dry/validation/schema/form'
