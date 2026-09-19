# frozen_string_literal: true

class SolidusAdmin::PaymentMethods::Edit::Component < SolidusAdmin::Resources::Edit::Component
  include SolidusAdmin::Layout::PageHelpers

  def back_url = solidus_admin.payment_methods_path
end
