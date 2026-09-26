# frozen_string_literal: true

class SolidusAdmin::UI::Forms::Field::Component < SolidusAdmin::BaseComponent
  extend SolidusAdmin::ComponentsHelper

  def initialize(label:, hint: nil, tip: nil, error: nil, input_attributes: nil, **attributes)
    @label = label
    @hint = hint
    @tip = tip
    @error = [error] if error.present?
    @attributes = attributes
    @input_attributes = input_attributes

    raise ArgumentError, "provide either a block or input_attributes" if content? && input_attributes
  end

  def self.text_field(form, method, object: nil, hint: nil, tip: nil, size: :m, **attributes)
    object_name, object, label, errors = extract_form_details(form, object, method)

    new(
      label:,
      hint:,
      tip:,
      error: errors,
      input_attributes: {
        name: "#{object_name}[#{method}]",
        tag: :input,
        size:,
        value: object.public_send(method),
        error: errors&.to_sentence&.capitalize,
        **attributes
      }
    )
  end

  def self.select(form, method, choices, object: nil, hint: nil, tip: nil, size: :m, **attributes)
    object_name, object, label, errors = extract_form_details(form, object, method)

    component("ui/forms/select").new(
      label:,
      hint:,
      tip:,
      size: size,
      name: "#{object_name}[#{method}]#{"[]" if attributes[:multiple].present?}",
      choices:,
      value: object.try(method),
      error: errors&.to_sentence&.capitalize,
      **attributes
    )
  end

  def self.select_taxons(form, method, **attributes)
    _object_name, object, label, errors = extract_form_details(form, object, method)

    # FIXME: Obviously don't merge this. This is for discussion. Two issues:.
    #
    #    1. Tom Select does not seem to take paths, only URLs.
    #    2. There is currently no mechanism for authenticating and using
    #       `solidus_api` routes in `solidus_admin`. What is the best
    #       approach?
    #
    insecure_result_url =
      Spree::Core::Engine.routes.url_helpers.api_taxons_url(
        host: "http://localhost:3000",
        params: {token: Spree.user_class.admin.first.spree_api_key}
      )

    selected_taxons = records_from(object, method)

    taxon_select_attributes = {
      choices: selected_taxons.map { [_1.pretty_name, _1.id] },
      errors:,
      label:,
      multiple: true,
      src: insecure_result_url,
      value: selected_taxons.map(&:id),
      "data-option-label-field": :pretty_name,
      "data-query-param": "q[pretty_name_cont]"
    }
    attributes = taxon_select_attributes.merge(attributes)

    select(form, method, attributes[:choices], **attributes)
  end

  def self.records_from(object, method)
    association_method = method.to_s.sub(/_id(s?)\z/, '\1')
    Array.wrap(object.try(association_method))
  end

  def self.text_area(form, method, object: nil, hint: nil, tip: nil, size: :m, **attributes)
    object_name, object, label, errors = extract_form_details(form, object, method)

    new(
      label:,
      hint:,
      tip:,
      error: errors,
      input_attributes: {
        name: "#{object_name}[#{method}]",
        size:,
        tag: :textarea,
        value: object.public_send(method),
        error: errors&.to_sentence&.capitalize,
        **attributes
      }
    )
  end

  def self.toggle(form, method, object: nil, hint: nil, tip: nil, size: :m, **attributes)
    object_name, object, label, errors = extract_form_details(form, object, method)

    new(
      label:,
      hint:,
      tip:,
      error: errors
    ).with_content(
      component("ui/forms/switch").new(
        name: "#{object_name}[#{method}]",
        size:,
        checked: object.public_send(method),
        include_hidden: true,
        **attributes
      )
    )
  end

  def self.extract_form_details(form, object, method)
    if form.is_a?(String)
      object_name = form
      raise ArgumentError, "Object must be provided when form name is a string" unless object
    elsif form.respond_to?(:object)
      object_name = form.object_name
      object = form.object
    else
      raise ArgumentError, "Invalid arguments: expected a form object or form.object_name and form.object"
    end

    errors = object.errors.messages_for(method).presence if object.respond_to?(:errors)
    label = object.class.human_attribute_name(method)

    [object_name, object, label, errors]
  end
end
