# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Address::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  VALID_TYPES = ['ship', 'bill'].freeze

  def initialize(order:, address:, user: nil, type: 'ship')
    @order = order
    @user = user
    @address = address
    @addresses = user&.addresses.to_a.reject(&:new_record?)
    @type = validate_address_type(type)
  end

  def form_id
    @form_id ||= "#{stimulus_id}--form-#{@type}-#{@order.id}"
  end

  def address_frame_id
    @table_frame_id ||= "#{stimulus_id}--#{@type}-address-frame-#{@order.id}"
  end

  def use_attribute
    case @type
    when 'ship'
      'use_shipping'
    when 'bill'
      'use_billing'
    end
  end

  def format_address(address)
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

  def validate_address_type(type)
    VALID_TYPES.include?(type) ? type : raise(ArgumentError, "Invalid address type: #{type}")
  end
end
