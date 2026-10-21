# frozen_string_literal: true

# Solidus provides preference fields that can be rendered in user-facing
# forms for preference-enabled model objects. For example. +Spree::Calculator+
# and +Spree::PaymentMethod+ subclasses are all preference-enabled. For
# more information about accessing preferences, see the +Spree::Preferences+
# class documentation.
#
# Always prefer to use Solidus's built-in preference types. See the full list
# provided by `solidus_core` at:
#
#   Spree::Preferences::FORM_FIELD_TYPES
#
# Only if none of the built-in preference types can be used, provide a preference
# field component to be rendered in the form. The component must integrate with
# admin payment method forms by using arguments described below.
#
# Your custom preference field type must also be marked as allowed in your
# Rails application or Solidus extension. See the relevant source code
# documentation in `solidus_core` at:
#
#   Spree::Preferences::PreferableClassMethods.allowed_admin_form_preference_types
#
# @param form [SolidusAdmin::FormBuilder] the current in-scope form object
# @param type [String] the class as a string for the current form object
# @param preference_name [String] the preference field name (i.e.
#   "preferred_color")
# @param args [Hash] a hash of additional input context for rendering
# @return [ViewComponent] an instance of preference field view component
class SolidusAdmin::UI::PreferenceFields::Base::Component < SolidusAdmin::BaseComponent
  def initialize(form:, type:, preference_name:, **args)
    @form = form
    @type = type
    @preference_name = preference_name
    @args = args

    # Some input components require a nil error argument, so we should
    # provide a value if none is given to avoid render errors.
    @args[:error] = nil if @args[:error].blank?
  end

  def call
    render component("ui/forms/field").new(
      label:,
      hint:,
      input_attributes: {**component_input_attributes, **@args}
    )
  end

  private

  def base_class = @type.constantize.base_class

  def component_input_attributes
    raise NotImplementedError,
      "implement `#component_input_attributes` in the subclass"
  end

  # Tries to find a relevant translation on the current preference-enabled
  # subclass, falling back to the base class. It also tries to locate +_html+
  # variants of the translation strings to render. Returns nil if no hint
  # translation can be located.
  #
  # Include hints in your own application by adding to your i18n YAML files.
  # For example:
  #
  #   my_application/spree_calculator_subclass:
  #     preferred_calculator_preference_name_html: "<p>Description of calculator preference with HTML.</p>"
  #     preferred_other_calculator_preference_name: "Other description of a calculator preference."
  #   spree/calculator:
  #     preferred_third_calculator_preference_name: "A fallback description for any calculator subclass."
  #
  # @return [String, nil] the hint translation
  def hint
    i18n_options = {default: nil}
    translation_key = "preferred_#{@preference_name}"
    html_translation_key = "#{translation_key}_html"

    [@type.underscore, base_class&.to_s&.underscore].compact.each do |class_path|
      html_candidate_translation =
        I18n.t("spree.hints.%s.%s" % [class_path, html_translation_key], **i18n_options)
          &.presence
          &.html_safe
      return html_candidate_translation if html_candidate_translation.present?

      candidate_translation =
        I18n.t("spree.hints.%s.%s" % [class_path, translation_key], **i18n_options)
      return candidate_translation if candidate_translation.present?
    end

    nil
  end

  def label
    @type.constantize.human_attribute_name("preferred_#{@preference_name}")
  end
end
