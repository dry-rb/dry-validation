module Dry
  module Rules
    module Presence
      module_function

      def call(value, switch = true, _validator = nil)
        result = {
          code: 'presence',
          options: switch
        }
        result if (switch && value.to_s.length == 0) || (!switch && value.to_s.length > 0)
      end
    end
  end
end
