# frozen_string_literal: true

module Solidus
  module NamespaceMigration
    module ControllerViewPaths
      module Extension
        def self.prepended(base)
          base.singleton_class.prepend ClassMethods
        end

        module ClassMethods
          private

          def local_prefixes
            [controller_path.sub('solidus/', 'spree/')]
          end
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
            Solidus::BaseController,
            'Solidus::Api::BaseController'.safe_constantize,
          ].compact.freeze
        end
      end
    end
  end
end
