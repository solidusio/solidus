# frozen_string_literal: true

module Solidus
  module NamespaceMigration
    module ModelNaming
      module Extension
        def initialize(*)
          super
          @i18n_key = @i18n_key.to_s.sub('solidus/', 'spree/').to_sym
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
            ActiveModel::Name
          ].compact.freeze
        end
      end
    end
  end
end
