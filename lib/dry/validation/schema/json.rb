require 'dry/validation/schema'

module Dry
  module Validation
    class Schema::JSON < Schema
      configure do |config|
        config.input_processor = :json
      end
    end
  end
end
