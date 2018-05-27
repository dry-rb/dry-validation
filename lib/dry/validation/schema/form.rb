require 'dry/validation/schema'
require 'dry/validation/schema/params'
require 'dry/types/compat/form_types'

module Dry
  module Validation
    Schema::Form = Schema::Params
  end
end
