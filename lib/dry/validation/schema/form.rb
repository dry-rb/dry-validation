require 'dry/validation/schema'

module Dry
  module Validation
    class Schema::Form < Schema
      configure do |config|
        config.input_processor = :form
      end
    end
  end
end
