# frozen_string_literal: true

class SolidusAdmin::Orders::Index::Component < SolidusAdmin::BaseComponent
  def initialize(page:)
    @page = page
  end

  class_attribute :row_fade, default: ->(order) { order.paid? && order.shipped? }

  def title
    Spree::Order.model_name.human.pluralize
  end

  def prev_page_path
    solidus_admin.url_for(**request.params, page: @page.number - 1, only_path: true) unless @page.first?
  end

  def next_page_path
    solidus_admin.url_for(**request.params, page: @page.next_param, only_path: true) unless @page.last?
  end

  def batch_actions
    []
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
        presentation: t('.filters.status'),
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
        presentation: t('.filters.shipment_state'),
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
        presentation: t('.filters.payment_state'),
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
        presentation: t('.filters.promotions'),
        combinator: 'or',
        attribute: "promotions_id",
        predicate: "in",
        options: Spree::Promotion.all.map do |promotion|
          [
            promotion.name,
            promotion.id
          ]
        end
      },
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
        if !row_fade.call(order)
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
