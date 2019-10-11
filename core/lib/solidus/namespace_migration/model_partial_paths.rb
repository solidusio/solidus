# frozen_string_literal: true

module Solidus
  module NamespaceMigration
    module ModelPartialPaths
      module Extension
        def to_partial_path
          super.sub('solidus/', 'spree/')
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
            Solidus::Base
          ].compact.freeze
        end
      end
    end
  end
end
