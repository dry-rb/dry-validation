require 'dry/schema/messages'

module Dry
  module Validation
    module Messages
      class YAML < Schema::Messages::YAML
        config.root = config.root.gsub('dry_schema', 'dry_validation')
        config.rule_lookup_paths = config.rule_lookup_paths.map { |path|
          path.gsub('dry_schema', 'dry_validation')
        }
      end

      if defined?(::I18n)
        class I18n < Schema::Messages::I18n
          config.root = config.root.gsub('dry_schema', 'dry_validation')
          config.rule_lookup_paths = config.rule_lookup_paths.map { |path|
            path.gsub('dry_schema', 'dry_validation')
          }
        end
      end

      # @api private
      def self.setup(config)
        messages = build(config)

        if config.messages_file && config.namespace
          messages.merge(config.messages_file).namespaced(config.namespace)
        elsif config.messages_file
          messages.merge(config.messages_file)
        elsif config.namespace
          messages.namespaced(config.namespace)
        else
          messages
        end
      end

      # @api private
      def self.build(config)
        klass =
          case config.messages
          when :yaml then default
          when :i18n then Messages::I18n
          else
            raise "+#{config.messages}+ is not a valid messages identifier"
          end

        klass.build
      end

      # @api private
      def self.default
        Messages::YAML
      end
    end
  end
end
