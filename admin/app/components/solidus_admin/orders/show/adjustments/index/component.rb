# frozen_string_literal: true

class SolidusAdmin::Orders::Show::Adjustments::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def model_class
    Spree::Adjustment
  end

  def back_url
    solidus_admin.order_path(@order)
  end

  def title
    t(".title", number: @order.number)
  end

  NBSP = "&nbsp;".html_safe

  def initialize(order:, adjustments:)
    @order = order
    @adjustments = adjustments
    @page = GearedPagination::Recordset.new(adjustments, per_page: adjustments.size).page(1)
  end

  def batch_actions
    [
      {
        label: t(".actions.lock"),
        action: solidus_admin.lock_order_adjustments_path(@order),
        method: :put,
        icon: "lock-line"
      },
      {
        label: t(".actions.unlock"),
        action: solidus_admin.unlock_order_adjustments_path(@order),
        method: :put,
        icon: "lock-unlock-line"
      },
      {
        label: t(".actions.delete"),
        action: spree.admin_order_adjustment_path(@order, '[]'),
        method: :delete,
        icon: "delete-bin-7-line"
      },
    ]
  end

  def search_key
    :label_cont
  end

  def search_url
    solidus_admin.order_adjustments_path(@order)
  end

  def columns
    [
      {
        header: :state,
        wrap: true,
        col: { class: 'w-[calc(5rem+2rem+2.5rem+1px)]' },
        data: ->(adjustment) {
          if adjustment.finalized?
            icon = 'lock-fill'
            title = t(".state.locked")
          else
            icon = 'lock-unlock-line'
            title = t(".state.unlocked")
          end
          icon_tag(icon, class: "w-5 h-5 align-middle") + tag.span(title)
        }
      },
      {
        header: :adjustable,
        col: { class: 'w-56' },
        data: ->(adjustment) {
          tag.figure(safe_join([
            render(component("ui/thumbnail").for(adjustment.adjustable, class: "basis-10")),
            figcaption_for_adjustable(adjustment),
          ]), class: "flex items-center gap-2")
        }
      },
      {
        header: :source,
        col: { class: "w-56" },
        data: ->(adjustment) {
          component_name = adjustment.source&.class&.table_name&.singularize
          component_key = ["orders/show/adjustments/index/source", component_name].compact.join("/")
          render component(component_key).new(adjustment)
        }
      },
      {
        header: :amount,
        col: { class: 'w-24' },
        data: ->(adjustment) { tag.span adjustment.display_amount.to_html, class: "grow text-right whitespace-nowrap" }
      },
      {
        header: tag.span(t(".actions.title"), class: 'sr-only'),
        col: { class: 'w-24' },
        wrap: false,
        data: ->(adjustment) do
          actions = []

          unless adjustment.source
            actions << link_to(
              t(".actions.edit"),
              spree.edit_admin_order_adjustment_path(@order, adjustment),
              class: 'body-link',
            )
          end

          if adjustment.finalized?
            actions << link_to(
              t(".actions.unlock"),
              solidus_admin.unlock_order_adjustments_path(@order, id: adjustment),
              "data-turbo-method": :put,
              "data-turbo-confirm": t('.confirm'),
              class: 'body-link',
            )
          else
            actions << link_to(
              t(".actions.lock"),
              solidus_admin.lock_order_adjustments_path(@order, id: adjustment),
              "data-turbo-method": :put,
              "data-turbo-confirm": t('.confirm'),
              class: 'body-link',
            )
            actions << link_to(
              t(".actions.delete"),
              spree.admin_order_adjustment_path(@order, adjustment),
              "data-turbo-method": :delete,
              "data-turbo-confirm": t('.confirm'),
              class: 'body-link !text-red-500',
            )
          end

          render component('ui/dropdown').new(
            direction: :right,
            class: 'relative w-fit m-auto',
          ).with_content(safe_join(actions))
        end
      },
    ]
  end

  def icon_thumbnail(name)
    render component("ui/thumbnail").new(src: svg_data_uri(icon_tag(name)))
  end

  def svg_data_uri(data)
    "data:image/svg+xml;base64,#{Base64.strict_encode64(data)}"
  end

  def figcaption_for_adjustable(adjustment)
    # ["Spree::LineItem", "Spree::Order", "Spree::Shipment"]
    record = adjustment.adjustable
    record_class = adjustment.adjustable_type&.constantize

    case record || record_class
    when Spree::LineItem
      variant = record.variant
      options_text = variant.options_text.presence

      description = options_text || variant.sku
      detail = link_to(variant.product.name, solidus_admin.product_path(record.variant.product), class: "body-link")
    when Spree::Order
      description = "#{Spree::Order.model_name.human} ##{record.number}"
      detail = record.display_total
    when Spree::Shipment
       description = "#{t('spree.shipment')} ##{record.number}"
       detail = link_to(record.shipping_method.name, spree.edit_admin_shipping_method_path(record.shipping_method), class: "body-link")
    when nil
      # noop
    else
      name_method = [:display_name, :name, :number].find { record.respond_to? _1 } if record
      price_method = [:display_amount, :display_total, :display_cost].find { record.respond_to? _1 } if record

      description = record_class.model_name.human
      description = "#{description} - #{record.public_send(name_method)}" if name_method

      # attempt creating a link
      url_options = [:admin, record, :edit, { only_path: true }]
      url = begin; spree.url_for(url_options); rescue NoMethodError => e; logger.error(e.to_s); nil end

      description = link_to(description, url, class: "body-link") if url
      detail = record.public_send(price_method) if price_method
    end

    thumbnail_caption(description, detail)
  end

  def thumbnail_caption(first_line, second_line)
    tag.figcaption(safe_join([
      tag.div(first_line || NBSP, class: 'text-black body-small whitespace-nowrap text-ellipsis overflow-hidden'),
      tag.div(second_line || NBSP, class: 'text-gray-500 body-small whitespace-nowrap text-ellipsis overflow-hidden')
    ]), class: "flex flex-col gap-0 max-w-[15rem]")
  end
end
