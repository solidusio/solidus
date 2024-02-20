# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Shipment::Split::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(shipment:)
    @order = shipment.order
    @shipment = shipment
  end

  def manifest
    Spree::ShippingManifest.new(
      inventory_units: @shipment.inventory_units.where(carton_id: nil),
    ).items.sort_by { |item| item.line_item.created_at }
  end

  def form_id
    dom_id(@order, "#{stimulus_id}_shipment_form_#{@shipment.id}")
  end


  def render_split_action_button
    render component("ui/button").new(
      name: request_forgery_protection_token,
      value: form_authenticity_token(form_options: {
        action: solidus_admin.split_create_order_shipment_path(@order, @shipment),
        method: :put,
      }),
      formaction: solidus_admin.split_create_order_shipment_path(@order, @shipment),
      formmethod: :put,
      form: form_id,
      text: t('.split'),
      type: :submit,
    )
  end

  def close_path
    @close_path ||= solidus_admin.order_path(@order)
  end
end
