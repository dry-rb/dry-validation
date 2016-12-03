require 'logger'
require 'dry/configurable'

module Dry
  module Validation
    module Deprecations
      extend Dry::Configurable

      setting :logger, Logger.new($stdout)

      def self.format(msg, caller)
        "#{msg} [#{caller[1].split(':')[0..1].join(' line ')}]"
      end

      def logger
        @logger ||= Deprecations.config.logger
      end

      def warn(msg)
        logger.warn(Deprecations.format(msg, ::Kernel.caller))
      end
    end
  end
end
