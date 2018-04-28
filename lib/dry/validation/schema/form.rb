require 'dry/validation/schema'
require 'dry/types/compat/form_types'

module Dry
  module Validation
    class Schema::Form < Schema
      def self.configure(klass = nil, &block)
        if klass
          klass.configure do |config|
            config.input_processor = :form
            config.hash_type = :symbolized
          end
          klass
        else
          super(&block)
        end
      end

      configure(self)
    end
  end
end
