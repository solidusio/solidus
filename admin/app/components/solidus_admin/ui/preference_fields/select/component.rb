# frozen_string_literal: true

class SolidusAdmin::UI::PreferenceFields::Select::Component < SolidusAdmin::UI::PreferenceFields::Base::Component
  def call
    render component("ui/forms/select").new(
      label:,
      name: @args[:name],
      hint:,
      choices: select_options,
      error: @error,
      value: @args[:value].presence,
      **@args
    )
  end

  private

  def klass = @type.constantize

  def select_options
    attribute_method = :"preferred_#{@preference_name}_options"
    namespace = "activerecord.attributes.#{klass.name.underscore}"

    return [] unless (options = klass.new.try(attribute_method))

    options.map { |option|
      key = option.to_s.parameterize.underscore
      label = I18n.t("#{namespace}.#{attribute_method}.#{key}", default: option)
      [label, option]
    }
  end
end
