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
          component_name = adjustment.adjustable&.class&.table_name&.singularize
          component_key = ["orders/show/adjustments/index/adjustable", component_name].compact.join("/")
          render component(component_key).new(adjustment)
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
end
