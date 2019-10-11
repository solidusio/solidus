# frozen_string_literal: true

module Solidus
  module NamespaceMigration
    module CustomValidationsI18n
      module Extension
        def validate_source
          if source && !source.valid?
            source.errors.each do |field, error|
              field_name = source.class.human_attribute_name(field)
              errors.add(I18n.t(source.class.to_s.demodulize.underscore, scope: 'spree'), "#{field_name} #{error}")
            end
          end
          if errors.any?
            throw :abort
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
            Solidus::Payment
          ].compact.freeze
        end
      end
    end
  end
end
