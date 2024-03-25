# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Shipment::Edit::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(shipment:)
    @order = shipment.order
    @shipment = shipment
  end

  def form_id
    dom_id(@order, "#{stimulus_id}_shipment_form_#{@shipment.id}")
  end

  def close_path
    @close_path ||= solidus_admin.order_path(@order)
  end
end
