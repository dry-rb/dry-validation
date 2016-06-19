require 'dry/validation/schema'

module Dry
  module Validation
    class Schema::JSON < Schema
      configure do |config|
        config.input_processor = :json
        config.hash_type = :symbolized
      end
    end
  end
end
