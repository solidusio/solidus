# frozen_string_literal: true

module Solidus
  module NamespaceMigration
    module ControllerBelongsTo
      module Extension
        def parent_model_name
          self.class.parent_data[:model_name].gsub('solidus/', '')
        end
      end

      class << self
        def activate
          affected_modules.each do |affected_module|
            affected_module.prepend Extension
          end
        end

        private

        def affected_modules
          [
            'Solidus::Admin::ResourceController'.safe_constantize
          ].compact.freeze
        end
      end
    end
  end
end
