require 'dry-configurable'
require 'dry-container'
require 'dry/validation/class_interface'
require 'dry/validation/processor'
require 'dry/validation/rule_set'
require 'dry/validation/version'

# A collection of micro-libraries, each intended to encapsulate
# a common task in Ruby
module Dry
  module Validation
    attr_reader :_subject
    private :_subject

    def self.included(klass)
      klass.__send__(:extend, ::Dry::Configurable)
      klass.__send__(:setting, :processor, Processor)
      klass.__send__(:extend, ClassInterface)
      klass.__send__(:instance_variable_set, :@rules, RuleSet.new)
    end

    def initialize(subject)
      @_subject = subject
    end

    def errors
      @errors ||= self.class.config.processor.call(_rules, _subject)
    end

    private

    def _rules
      self.class.rules
    end
  end
end
