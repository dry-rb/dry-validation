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
  #     => {:name=>[{:code=>"presence", :value=>"", :options=>true}]}
  #
  # @api public
  class Validator
    extend ::Dry::Configurable

    # @return [Hash] Rules hash
    attr_reader :rules
    # @return [Mixed] Validation processor
    attr_reader :processor

    setting :default_processor, ::Dry::Validator::Processor

    # Create a new validator
    #
    # @param [Hash] rules or options
    # @option options [Hash] :rules Validation rules
    # @option options [Mixed] :processor Validation processor
    #
    # @return Dry::Validator self
    #
    # @api public
    def initialize(options = {})
      if options.fetch(:rules, false)
        @rules = options.fetch(:rules, {})
        @processor = options.fetch(:processor, default_processor)
      else
        @rules = options
        @processor = default_processor
      end
    end

    # Create a new validator
    #
    # @param [Dry::Validator] other
    #
    # @return Dry::Validator
    #
    # @api public
    def merge(other)
      self.class.new(
        rules: rules.merge(other.rules),
        processor: processor
      )
    end
    alias_method :<<, :merge

    # Create a new validator
    #
    # @param [Object] subject The subject to validate
    #
    # @return Dry::Validator
    #
    # @api public
    def call(subject)
      processor.call(self, subject)
    end
    alias_method :validate, :call

    private

    # @api private
    def default_processor
      self.class.config.default_processor
    end
  end
end
