# frozen_string_literal: true

module Spree
  module Admin
    module PreferenceFieldsHelper
      def preference_field_for(form, name)
        preference_type = form.object.preference_type(name)

        render "spree/admin/shared/preference_fields/#{preference_type}",
          form:,
          attribute: "preferred_#{name}",
          label: I18n.t(name, scope: "spree", default: name.to_s.humanize),
          options: preference_select_options(object: form.object, name:)
      end

      private

      def preference_select_options(object:, name:)
        attribute_method = :"preferred_#{name}_options"

        return nil unless (options = object.try(attribute_method))

        namespace = "activerecord.attributes.#{object.class.name.underscore}"

        options.map { |option|
          key = option.to_s.parameterize.underscore
          label = I18n.t("#{namespace}.#{attribute_method}.#{key}", default: option.to_s)
          [label, option]
        }
      end
    end
  end
end
