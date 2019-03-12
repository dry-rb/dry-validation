# frozen_string_literal: true

module Dry
  module Validation
    module Messages
      class YAML < Schema::Messages::YAML
        config.root = config.root.gsub('dry_schema', 'dry_validation')
        config.rule_lookup_paths = config.rule_lookup_paths.map { |path|
          path.gsub('dry_schema', 'dry_validation')
        }
      end
    end
  end
end
