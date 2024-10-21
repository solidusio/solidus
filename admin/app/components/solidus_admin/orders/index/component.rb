# frozen_string_literal: true

class SolidusAdmin::Orders::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def model_class
    Spree::Order
  end

  def search_key
    :number_or_shipments_number_or_bill_address_name_or_email_cont
  end

  def search_url
    solidus_admin.orders_path(scope: params[:scope])
  end

  def row_url(order)
    spree.edit_admin_order_path(order)
  end

  def row_fade(order)
    order.paid? && order.shipped?
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t('.add'),
      href: spree.new_admin_order_path,
      icon: "add-line",
    )
  end

  def scopes
    [
      { label: t('.scopes.complete'), name: 'completed', default: true },
      { label: t('.scopes.in_progress'), name: 'in_progress' },
      { label: t('.scopes.returned'), name: 'returned' },
      { label: t('.scopes.canceled'), name: 'canceled' },
      { label: t('.scopes.all_orders'), name: 'all' },
    ]
  end

  def filters
    [
      {
        label: t('.filters.status'),
        combinator: 'or',
        attribute: "state",
        predicate: "eq",
        options: Spree::Order.state_machines[:state].states.map do |state|
          [
            state.value.titleize,
            state.value
          ]
        end
      },
      {
        label: t('.filters.shipment_state'),
        combinator: 'or',
        attribute: "shipment_state",
        predicate: "eq",
        options: %i[backorder canceled partial pending ready shipped].map do |option|
          [
            option.to_s.capitalize,
            option
          ]
        end
      },
      {
        label: t('.filters.payment_state'),
        combinator: 'or',
        attribute: "payment_state",
        predicate: "eq",
        options: %i[balance_due checkout completed credit_owed invalid paid pending processing void].map do |option|
          [
            option.to_s.titleize,
            option
          ]
        end
      },
      {
        label: t('.filters.store'),
        combinator: 'or',
        attribute: "store_id",
        predicate: "eq",
        options: Spree::Store.all.pluck(:name, :id)
      }
    ]
  end

  def columns
    [
      number_column,
      state_column,
      date_column,
      customer_column,
      total_column,
      items_column,
      payment_column,
      shipment_column,
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
        component('ui/badge').new(name: order.state.humanize, color:)
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

  def customer_column
    {
      col: { class: "w-[400px]" },
      header: :customer,
      data: ->(order) do
        customer_email = order.user&.email
        content_tag :div, String(customer_email)
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

  def items_column
    {
      header: :items,
      data: ->(order) do
        content_tag :div, t('.columns.items', count: order.line_items.sum(:quantity))
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
