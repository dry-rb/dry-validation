module Dry
  module Validation
    class Schema
      class Attr < Key
        attr_reader :name, :target

        def identifier
          :attr
        end
      end
    end
  end
end
