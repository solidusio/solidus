# frozen_string_literal: true

class SolidusAdmin::FormBuilder < ActionView::Helpers::FormBuilder
  include SolidusAdmin::ComponentsHelper

  delegate :render, to: :@template

  def text_field(method, **options)
    render component("ui/forms/field").text_field(self, method, **options)
  end

  def text_area(method, **options)
    render component("ui/forms/field").text_area(self, method, **options)
  end

  def select(method, choices, **options)
    render component("ui/forms/field").select(self, method, choices, **options)
  end

  def checkbox(method, checked: nil, **options, &block)
    checked = @object.public_send(method) if checked.nil?
    component_instance = component("ui/forms/checkbox").new(object_name: @object_name, checked:, method:, **options)
    render component_instance, &block
  end

  def checkbox_row(method, options:, row_title:, **attrs)
    render component("ui/checkbox_row").new(form: self, method:, options:, row_title:, **attrs)
  end

  def input(method, **options)
    name = "#{@object_name}[#{method}]"
    value = @object.public_send(method) if options[:value].nil?
    render component("ui/forms/input").new(name:, value:, **options)
  end

  def hidden_field(method, **options)
    input(method, type: :hidden, autocomplete: "off", **options)
  end

  def switch_field(method, label: nil, include_hidden: true, **options)
    label = @object.class.human_attribute_name(method) if label.nil?
    name = "#{@object_name}[#{method}]"
    error = @object.errors[method]
    checked = @object.public_send(method)
    render component("ui/forms/switch_field").new(label:, name:, error:, checked:, include_hidden:, **options)
  end

  def submit(**options)
    render component("ui/button").submit(resource: @object, form: id, **options)
  end
end
