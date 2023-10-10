# frozen_string_literal: true

class SolidusAdmin::Orders::Index::Component < SolidusAdmin::BaseComponent
  def initialize(page:)
    @page = page
  end

  class_attribute :fade_row_proc, default: ->(order) { order.paid? && order.shipped? }

  def title
    Spree::Order.model_name.human.pluralize
  end

  def prev_page_link
    @page.first? ? nil : solidus_admin.url_for(host: request.host, port: request.port, **request.params, page: @page.number - 1)
  end

  def next_page_link
    @page.last? ? nil : solidus_admin.url_for(host: request.host, port: request.port, **request.params, page: @page.next_param)
  end

  def batch_actions
    []
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
        presentation: t('.filters.variants'),
        combinator: 'or',
        attribute: "line_items_variant_id",
        predicate: "in",
        options: Spree::Variant.all.map do |variant|
          [
            variant.descriptive_name,
            variant.id
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
        order_path = spree.edit_admin_order_path(order)

        if !fade_row_proc.call(order)
          link_to order.number, order_path, class: 'font-semibold'
        else
          link_to order.number, order_path
        end
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
      class_name: "w-[400px]",
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
        component('ui/badge').new(name: order.payment_state&.humanize, color: order.paid? ? :green : :yellow)
      end
    }
  end

  def shipment_column
    {
      header: :shipment,
      data: ->(order) do
        component('ui/badge').new(name: order.shipment_state&.humanize, color: order.shipped? ? :green : :yellow)
      end
    }
  end
end
