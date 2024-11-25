# frozen_string_literal: true

class SolidusAdmin::Users::Items::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(user:, items:)
    @user = user
    @items = items
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
        current: false,
      },
      {
        text: t('.items'),
        href: solidus_admin.items_user_path(@user),
        current: true,
      },
      {
        text: t('.store_credit'),
        href: spree.admin_user_store_credits_path(@user),
        current: false,
      },
    ]
  end

  def model_class
    Spree::LineItem
  end

  def row_url(order)
    spree.edit_admin_order_path(order)
  end

  def rows
    @items
  end

  def columns
    [
      date_column,
      image_column,
      description_column,
      price_column,
      quantity_column,
      total_column,
      state_column,
      number_column,
    ]
  end

  def date_column
    {
      col: { class: "w-[8%]" },
      header: :date,
      data: ->(item) do
        content_tag :div, l(item.order.created_at, format: :short), class: "text-sm"
      end
    }
  end

  def image_column
    {
      col: { class: "w-[8%]" },
      header: tag.span('aria-label': Spree::Image.model_name.human, role: 'text'),
      data: ->(item) do
        image = item.variant.gallery.images.first || item.variant.product.gallery.images.first or return

        render(
          component('ui/thumbnail').new(
            src: image.url(:small),
            alt: item.product.name
          )
        )
      end
    }
  end

  def description_column
    {
      col: { class: "w-[24%]" },
      header: t(".description_column_header"),
      data: ->(item) { item_name_with_variant_and_sku(item) }
    }
  end

  def price_column
    {
      col: { class: "w-[10%]" },
      header: :price,
      data: ->(item) do
        content_tag :div, item.single_money.to_html
      end
    }
  end

  def quantity_column
    {
      col: { class: "w-[7%]" },
      header: :qty,
      data: ->(item) do
        content_tag :div, item.quantity
      end
    }
  end

  def total_column
    {
      col: { class: "w-[10%]" },
      header: t(".total_column_header"),
      data: ->(item) do
        content_tag :div, item.money.to_html
      end
    }
  end

  def state_column
    {
      col: { class: "w-[15%]" },
      header: :state,
      data: ->(item) do
        color = {
          'complete' => :green,
          'returned' => :red,
          'canceled' => :blue,
          'cart' => :graphite_light,
        }[item.order.state] || :yellow
        component('ui/badge').new(name: item.order.state.humanize, color: color)
      end
    }
  end

  def number_column
    {
      col: { class: "w-[18%]" },
      header: t(".number_column_header"),
      data: ->(item) do
        link_to item.order.number, row_url(item.order), class: "underline cursor-pointer font-semibold text-sm"
      end
    }
  end

  private

  def item_name_with_variant_and_sku(item)
    content = []
    content << item.product.name
    content << "(#{item.variant.options_text})" if item.variant.option_values.any?
    content << "<strong>#{t('spree.sku')}:</strong> #{item.variant.sku}" if item.variant.sku.present?

    # The `.html_safe` is required for the description to display as desired.
    # rubocop:disable Rails/OutputSafety
    safe_join([link_to(content.join("<br>").html_safe, row_url(item.order), class: "underline cursor-pointer text-sm")])
    # rubocop:enable Rails/OutputSafety
  end
end
