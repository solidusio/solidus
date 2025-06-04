# frozen_string_literal: true

class SolidusAdmin::Users::Addresses::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(user:, address: nil, type: nil)
    @user = user
    @bill_address = bill_address(address, type)
    @ship_address = ship_address(address, type)
  end

  def form_id
    @form_id ||= "#{stimulus_id}--form-#{@user.id}"
  end

  def bill_address(address, type)
    if address.present? && type == "bill"
      address
    else
      @user.bill_address || Spree::Address.build_default
    end
  end

  def ship_address(address, type)
    if address.present? && type == "ship"
      address
    else
      @user.ship_address || Spree::Address.build_default
    end
  end
end
