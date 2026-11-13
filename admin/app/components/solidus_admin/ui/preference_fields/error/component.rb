# frozen_string_literal: true

class SolidusAdmin::UI::PreferenceFields::Error::Component < SolidusAdmin::UI::PreferenceFields::Base::Component
  def call
    render component("ui/alert").new(
      title: t(".title", label:),
      message: t(
        ".message",
        preference_type: @args[:preference_type],
        error: @error&.to_sentence
      ),
      dismissable: false,
      scheme: :danger
    )
  end
end
