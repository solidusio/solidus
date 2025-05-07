# frozen_string_literal: true

class SolidusAdmin::ShippingMethods::Form::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(shipping_method:, id:, url:)
    @shipping_method = shipping_method
    @id = id
    @url = url
    @calculators = Rails.application.config.spree.calculators.shipping_methods
  end
end
