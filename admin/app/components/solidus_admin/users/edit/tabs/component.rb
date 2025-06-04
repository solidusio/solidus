# frozen_string_literal: true

class SolidusAdmin::Users::Edit::Tabs::Component < SolidusAdmin::BaseComponent
  def initialize(user:, current:)
    @user = user
    @current = current
  end

  def call
    rendered_tabs = tabs.map do |tab|
      render component("ui/button").new(tag: :a, scheme: :ghost, text: tab[:text], 'aria-current': tab[:current], href: tab[:href])
    end

    safe_join(rendered_tabs)
  end

  def tabs
    [
      {
        text: t(".account"),
        href: solidus_admin.user_path(@user),
        current: @current == :account,
      },
      {
        text: t(".addresses"),
        href: solidus_admin.addresses_user_path(@user),
        current: @current == :addresses,
      },
      {
        text: t(".order_history"),
        href: solidus_admin.orders_user_path(@user),
        current: @current == :orders,
      },
      {
        text: t(".items"),
        href: solidus_admin.items_user_path(@user),
        current: @current == :items,
      },
      {
        text: t(".store_credit"),
        href: solidus_admin.user_store_credits_path(@user),
        current: @current == :store_credits,
      },
    ]
  end
end
