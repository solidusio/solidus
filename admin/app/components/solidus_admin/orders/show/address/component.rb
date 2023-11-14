# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Address::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  VALID_TYPES = ['ship', 'bill'].freeze

  def initialize(order:, address:, type: 'ship')
    @order = order
    @type = validate_address_type(type)
    @address = address
  end

  def form_id
    @form_id ||= "#{stimulus_id}--form-#{@type}-#{@order.id}"
  end

  def use_attribute
    case @type
    when 'ship'
      'use_shipping'
    when 'bill'
      'use_billing'
    end
  end

  def validate_address_type(type)
    VALID_TYPES.include?(type) ? type : raise(ArgumentError, "Invalid address type: #{type}")
  end
end
