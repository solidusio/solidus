# frozen_string_literal: true

class SolidusAdmin::PaymentMethods::Form::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(payment_method:, url:, form_id:)
    @payment_method = payment_method
    @url = url
    @form_id = form_id
  end
end
