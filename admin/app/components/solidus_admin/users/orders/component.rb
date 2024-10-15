# frozen_string_literal: true

class SolidusAdmin::Users::Orders::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(user:, orders:)
    @user = user
    @orders = orders
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
        current: false,
      },
      {
        text: t('.order_history'),
        href: solidus_admin.orders_user_path(@user),
        current: true,
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

  def model_class
    Spree::Order
  end

  def row_url(order)
    spree.edit_admin_order_path(order)
  end

  def rows
    @orders
  end

  def row_fade(_order)
    false
  end

  def columns
    [
      number_column,
      state_column,
      date_column,
      payment_column,
      shipment_column,
      total_column,
    ]
  end

  def number_column
    {
      header: :order,
      data: ->(order) do
        if !row_fade(order)
          content_tag :div, order.number, class: 'font-semibold'
        else
          content_tag :div, order.number
        end
      end
    }
  end

  def state_column
    {
      header: :state,
      data: ->(order) do
        color = {
          'complete' => :green,
          'returned' => :red,
          'canceled' => :blue,
          'cart' => :graphite_light,
        }[order.state] || :yellow
        component('ui/badge').new(name: order.state.humanize, color: color)
      end
    }
  end

  def date_column
    {
      header: :date,
      data: ->(order) do
        content_tag :div, l(order.created_at, format: :short)
      end
    }
  end

  def total_column
    {
      header: :total,
      data: ->(order) do
        content_tag :div, number_to_currency(order.total)
      end
    }
  end

  def payment_column
    {
      header: :payment,
      data: ->(order) do
        component('ui/badge').new(name: order.payment_state.humanize, color: order.paid? ? :green : :yellow) if order.payment_state?
      end
    }
  end

  def shipment_column
    {
      header: :shipment,
      data: ->(order) do
        component('ui/badge').new(name: order.shipment_state.humanize, color: order.shipped? ? :green : :yellow) if order.shipment_state?
      end
    }
  end
end
