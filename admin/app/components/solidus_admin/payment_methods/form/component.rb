# frozen_string_literal: true

class SolidusAdmin::PaymentMethods::Form::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(payment_method:, url:, form_id:)
    @payment_method = payment_method
    @url = url
    @form_id = form_id
  end

  def auto_capture_select_options
    current_app_default =
      Spree::Config.auto_capture ? t(".auto_capture.yes_setting") : t(".auto_capture.no_setting")

    [
      [t(".auto_capture.app_default", current_app_default:), ""],
      [t(".auto_capture.yes_setting"), true],
      [t(".auto_capture.no_setting"), false]
    ]
  end

  def available_preference_sources
    Spree::PaymentMethod.available_preference_sources
  end

  def available_types
    Rails.application.config.spree.payment_methods.sort_by(&:name)
  end

  def store_select_values
    Spree::Store.pluck(:name, :id)
  end
end
