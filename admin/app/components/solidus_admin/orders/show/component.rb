# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(order:)
    @order = order
  end

  def form_id
    @form_id ||= "#{stimulus_id}--form-#{@order.id}"
  end

  def format_address(address)
    return unless address
    safe_join([
      address.name,
      tag.br,
      address.address1,
      tag.br,
      address.address2,
      address.city,
      address.zipcode,
      address.state&.name,
      tag.br,
      address.country.name,
      tag.br,
      address.phone,
    ], " ")
  end

  def turbo_frames
    %w[edit_order_email_modal]
  end

  def customer_name(user)
    (
      user.default_user_bill_address ||
      user.default_user_ship_address ||
      user.user_addresses.where(default: true).first ||
      user.user_addresses.first
    )&.address&.name
  end
end
