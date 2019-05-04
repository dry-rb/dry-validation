# frozen_string_literal: true

require 'dry/container/mixin'

module Dry
  module Validation
    module Macros
      extend Container::Mixin

      # @api public
      Acceptance = proc do
        key_name = keys[0]
        key.failure(:acceptance, key: key_name) unless values[key_name].equal?(true)
      end

      register(:acceptance, Acceptance, call: false)
    end
  end
end
