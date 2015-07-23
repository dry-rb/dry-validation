module Dry
  class Validator
    module Rules
      # @api private
      class Registry < ::Dry::Container::Registry
        def call(container, key, item, options)
          super(container, key, item, options.merge(call: false))
        end
      end
    end
  end
end
