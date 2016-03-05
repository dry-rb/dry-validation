module Dry
  module Validation
    class Schema
      class Attr < Key
        def self.type
          :attr
        end

        def class
          Attr
        end
      end
    end
  end
end
