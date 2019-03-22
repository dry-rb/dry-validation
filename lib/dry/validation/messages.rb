# frozen_string_literal: true

require 'dry/schema/messages'

require 'dry/validation/messages/yaml'
require 'dry/validation/messages/i18n' if defined?(I18n)

module Dry
  module Validation
    module Messages
      extend Schema::Messages
    end
  end
end
