require 'thread_safe'
require 'dry-configurable'
require 'dry-container'
require 'dry/validator/processor'
require 'dry/validator/version'

# A collection of micro-libraries, each intended to encapsulate
# a common task in Ruby
module Dry
  # A simple, configurable, stand-alone validator
  #
  # @example
  #
  #   User = Struct.new(:name)
  #
  #   user_validator = Dry::Validator.new(
  #     name: {
  #       presence: true
  #     }
  #   )
  #
  #   user = User.new('')
  #   user_validator.call(user)
  #     => {:name=>[{:code=>"presence", :options=>true}]}
  #
  # @api public
  class Validator
    extend ::Dry::Configurable

    attr_reader :rules, :processor

    setting :default_processor, ::Dry::Validator::Processor

    def initialize(options = {})
      if options.fetch(:rules, false)
        @rules = options.fetch(:rules, {})
        @processor = options.fetch(:processor, default_processor)
      else
        @rules = options
        @processor = default_processor
      end
    end

    def merge(other)
      self.class.new(
        rules: rules.merge(other.rules),
        processor: processor
      )
    end
    alias_method :<<, :merge

    def call(attributes)
      processor.call(self, attributes)
    end
    alias_method :validate, :call

    private

    def default_processor
      self.class.config.default_processor
    end
  end
end
