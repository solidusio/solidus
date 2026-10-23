# frozen_string_literal: true

class SolidusAdmin::UI::PreferenceFields::Boolean::Component < SolidusAdmin::UI::PreferenceFields::Base::Component
  def call
    checked = ActiveModel::Type::Boolean.new.cast(@args.delete(:value))

    args = @args.merge(
      checked:,
      include_hidden: true,
      label:,
      hint:
    )
    render component("ui/forms/switch_field").new(**args)
  end
end
