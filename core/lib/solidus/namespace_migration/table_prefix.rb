# frozen_string_literal: true

module Solidus
  module NamespaceMigration
    module TablePrefix
      module Extension
        def self.prepended(base)
          base.singleton_class.prepend ClassMethods
        end

        module ClassMethods
          def table_name_prefix
            'spree_'
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
            Solidus
          ].compact.freeze
        end
      end
    end
  end
end
