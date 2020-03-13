# frozen_string_literal: true

module Spree
  module Admin
    module BaseHelper
      def field_container(model, method, options = {}, &block)
        css_classes = options[:class].to_a
        css_classes << 'field'
        if error_message_on(model, method).present?
          css_classes << 'withError'
        end
        content_tag(:div, capture(&block), class: css_classes.join(' '), id: "#{model}_#{method}_field")
      end

      def error_message_on(object, method, _options = {})
        object = convert_to_model(object)
        obj = object.respond_to?(:errors) ? object : instance_variable_get("@#{object}")

        if obj && obj.errors[method].present?
          errors = safe_join(obj.errors[method], "<br />".html_safe)
          content_tag(:span, errors, class: 'formError')
        else
          ''
        end
      end

      def admin_hint(title, text)
        content_tag(:span, class: 'hint-tooltip', title: title, data: { content: text }) do
          content_tag(:i, '', class: 'fa fa-info-circle')
        end
      end

      def datepicker_field_value(date, with_time: false)
        return if date.blank?

        format = if with_time
          t('spree.date_picker.format_with_time', default: '%Y/%m/%d %H:%M')
        else
          t('spree.date_picker.format', default: '%Y/%m/%d')
        end

        l(date, format: format)
      end

      # @deprecated Render `spree/admin/shared/preference_fields/\#{preference_type}' instead
      def preference_field_tag(name, value, options)
        type = options.delete(:type) || :text
        render "spree/admin/shared/preference_fields/#{type}",
          name: name, value: value, html_options: options
      end
      deprecate preference_field_tag:
        "Render `spree/admin/shared/preference_fields/\#{preference_type}' instead",
        deprecator: Spree::Deprecation

      # @deprecated Render `spree/admin/shared/preference_fields/\#{preference_type}' instead
      def preference_field_for(form, field, options)
        type = options.delete(:type) || :text
        render "spree/admin/shared/preference_fields/#{type}",
          form: form, attribute: field, html_options: options
      end
      deprecate preference_field_for:
        "Render `spree/admin/shared/preference_fields/\#{preference_type}' instead",
        deprecator: Spree::Deprecation

      # @deprecated Pass an `html_options' hash into preference field partial instead
      def preference_field_options(options)
        field_options = case options[:type]
                        when :integer
          { size: 10,
            class: 'input_integer' }
                        when :boolean
          {}
                        when :string
          { size: 10,
            class: 'input_string fullwidth' }
                        when :password
          { size: 10,
            class: 'password_string fullwidth' }
                        when :text
          { rows: 15,
            cols: 85,
            class: 'fullwidth' }
        else
          { size: 10,
            class: 'input_string fullwidth' }
        end

        field_options.merge!({
          readonly: options[:readonly],
          disabled: options[:disabled],
          size: options[:size]
        })
      end
      deprecate preference_field_options: "Pass an `html_options' hash into " \
        "`render('spree/admin/shared/preference_fields/\#{preference_type}')` instead)",
        deprecator: Spree::Deprecation

      # @deprecated Please render each preference keys partial instead. Example:
      # <% @object.preferences.keys.each do |key| %>
      #   <%= render "spree/admin/shared/preference_fields/#{@object.preference_type(key)}",
      #     form: f, attribute: "preferred_#{key}", label: t(key, scope: 'spree') %>
      # <% end %>
      def preference_fields(object, form)
        return unless object.respond_to?(:preferences)
        capture do
          object.preferences.keys.each do |key|
            concat render("spree/admin/shared/preference_fields/#{object.preference_type(key)}",
              form: form, attribute: "preferred_#{key}", label: t(key, scope: 'spree'))
          end
        end
      end
      deprecate preference_fields: "Please render each preference key's partial instead. Example: \n" \
        "<% @object.preferences.keys.each do |key| %>\n" \
          "<%= render \"spree/admin/shared/preference_fields/\#{@object.preference_type(key)}\", \n" \
             "form: f, attribute: \"preferred_\#{key}\", label: t(key, scope: 'spree') %>\n" \
        "<% end %>", deprecator: Spree::Deprecation

      def link_to_add_fields(name, target, options = {})
        name = '' if options[:no_text]
        css_classes = options[:class] ? options[:class] + " spree_add_fields" : "spree_add_fields"
        link_to_with_icon('plus', name, 'javascript:', data: { target: target }, class: css_classes)
      end
      deprecate link_to_add_fields: "Please use button_tag instead, Example: \n" \
        "button_tag \"Name\", type: \"button\", data: { target: \"tbody#div\" }", deprecator: Spree::Deprecation

      # renders hidden field and link to remove record using nested_attributes
      def link_to_remove_fields(name, form, options = {})
        name = '' if options[:no_text]
        options[:class] = '' unless options[:class]
        options[:class] += 'no-text with-tip' if options[:no_text]
        url = form.object.persisted? ? [:admin, form.object] : '#'
        link_to_with_icon('trash', name, url, class: "spree_remove_fields #{options[:class]}", data: { action: 'remove' }, title: t('spree.actions.remove')) +
          form.hidden_field(:_destroy)
      end

      def spree_dom_id(record)
        dom_id(record, 'spree')
      end

      def admin_layout(layout = nil)
        @admin_layout = layout if layout
        @admin_layout
      end
    end
  end
end
