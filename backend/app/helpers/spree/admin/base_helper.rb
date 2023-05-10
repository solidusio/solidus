# frozen_string_literal: true

module Spree
  module Admin
    module BaseHelper
      def admin_component(name, locals = {})
        partial_path = "solidus_admin/components/#{name}/index"
        virtual_path = "solidus_admin/components/#{name}/_index"
        
        helper_class = partial_path.classify
        if Object.const_defined?(helper_class)
          helper = helper_class.constantize.new(
            view_context: self, virtual_path: virtual_path, locals: locals
          )
        end

        {partial: partial_path, locals: { helper: helper, **locals }}
      end

      def stimulus_id
        @virtual_path.gsub(%r{/_?}, '--').tr('_', '-')
      end

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
          errors = safe_join(obj.errors[method], "<br>".html_safe)
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
