# frozen_string_literal: true

#
# Allow some application_helper methods to be used in the scoped form_for manner
#
class ActionView::Helpers::FormBuilder
  def field_container(method, options = {}, &block)
    @template.field_container(@object_name, method, options, &block)
  end

  def error_message_on(method, options = {})
    @template.error_message_on(@object_name, method, objectify_options(options))
  end

  def field_hint(method, options = {})
    title = options[:title] || @object.class.human_attribute_name(method)
    text = options[:text] || I18n.t(method, scope: [:spree, :hints, @object.class.model_name.i18n_key])
    @template.admin_hint(title, text)
  end
end

ActionView::Base.field_error_proc = proc{ |html_tag, _instance| "<span class=\"field_with_errors\">#{html_tag}</span>".html_safe }
