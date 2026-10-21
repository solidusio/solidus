# frozen_string_literal: true

class SolidusAdmin::PaymentMethods::Form::Deployment::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(form:)
    @form = form
  end

  def f = @form

  def available_preference_sources
    return [] unless (klass = @type&.constantize)
    return [] unless klass <= Spree::PaymentMethod

    klass.available_preference_sources
  end

  def available_type_select_options
    Rails.application.config.spree.payment_methods.sort_by(&:name).map {
      [_1.model_name.human, _1.to_s]
    }
  end

  def current_type_instance = @current_type_instance ||= @type&.constantize&.new

  def field_for(preference_name, current_value)
    field_type = current_type_instance.preference_type(preference_name)
    field_args = {
      disabled: static_preference_source?,
      form: @form,
      type: @type,
      name: "payment_method[preferred_#{preference_name}]",
      preference_name:,
      # Ensure that false boolean values are not ignored before falling back to
      # a default value.
      value: ((field_type == :boolean) ? current_value&.to_s&.presence : current_value) ||
        current_type_instance.preference_default(preference_name)
    }

    component("ui/preference_fields/#{field_type}").new(**field_args)
  end

  def static_preference_source?
    @has_static_preference_source ||=
      available_preference_sources.any? && @preference_source.present?
  end

  def stimulus_attributes
    {"data-controller": stimulus_id}
  end

  def selected_preference_source_settings
    return {} unless @preference_source

    @type.constantize.preference_sources[@preference_source]&.preferences || {}
  end

  private

  def before_render
    @preference_source =
      if (source = params.dig(:payment_method, :preference_source))
        source
      else
        @form.object.preference_source
      end

    @type = params.dig(:payment_method, :type) || @form.object.type
  end
end
