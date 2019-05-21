# frozen_string_literal: true

require 'dry/equalizer'

module Dry
  module Validation
    module Messages
      # Template wraps a string with interpolation tokens and defines evaluator function
      # dynamically
      #
      # @api private
      class Template
        include Dry::Equalizer(:text)

        TOKEN_REGEXP = /%{(\w*)}/

        # !@attribute [r] text
        # @return [String]
        attr_reader :text

        # !@attribute [r] tokens
        # @return [Hash]
        attr_reader :tokens

        # !@attribute [r] evaluator
        # @return [Proc]
        attr_reader :evaluator

        # @api private
        def self.[](input)
          new(*parse(input))
        end

        # @api private
        def self.parse(input)
          tokens = input.scan(TOKEN_REGEXP).flatten(1).map(&:to_sym)
          text = input.gsub('%', '#')

          evaluator = <<-RUBY.strip
            -> (#{tokens.map { |token| "#{token}:" }.join(", ")}) { "#{text}" }
          RUBY

          [text, tokens, eval(evaluator, binding, __FILE__, __LINE__ - 3)]
        end

        # @api private
        def initialize(text, tokens, evaluator)
          @text = text
          @tokens = tokens
          @evaluator = evaluator
        end

        # @api private
        def data(input)
          tokens.each_with_object({}) { |k, h| h[k] = input[k] }
        end

        # @api private
        def call(data = EMPTY_HASH)
          data.empty? ? evaluator.() : evaluator.(data)
        end
        alias_method :[], :call
      end
    end
  end
end
