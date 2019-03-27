# frozen_string_literal: true

require 'hotch'
require 'i18n'

require 'dry-validation'

def profile(&block)
  Hotch(filter: 'Dry', &block)
end
