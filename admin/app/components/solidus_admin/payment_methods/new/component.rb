# frozen_string_literal: true

class SolidusAdmin::PaymentMethods::New::Component < SolidusAdmin::Resources::New::Component
  include SolidusAdmin::Layout::PageHelpers

  def back_url = solidus_admin.payment_methods_path
end
