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

  def tabs
    [
      {
        text: t('.account'),
        href: solidus_admin.user_path(@user),
        current: false,
      },
      {
        text: t('.addresses'),
        href: solidus_admin.addresses_user_path(@user),
        current: true,
      },
      {
        text: t('.order_history'),
        href: solidus_admin.orders_user_path(@user),
        current: false,
      },
      {
        text: t('.items'),
        href: spree.items_admin_user_path(@user),
        current: false,
      },
      {
        text: t('.store_credit'),
        href: spree.admin_user_store_credits_path(@user),
        current: false,
      },
    ]
  end

  def last_login(user)
    return t('.last_login.never') if user.try(:last_sign_in_at).blank?

    t(
      '.last_login.login_time_ago',
      # @note The second `.try` is here for the specs and for setups that use a
      # custom User class which may not have this attribute.
      last_login_time: time_ago_in_words(user.try(:last_sign_in_at))
    ).capitalize
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
