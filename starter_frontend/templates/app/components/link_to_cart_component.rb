# frozen_string_literal: true

class LinkToCartComponent < ViewComponent::Base
  delegate :current_order, :spree, to: :helpers

  def call
    link_to text.html_safe, cart_path, class: "cart-info block #{css_class} w-6 h-6", title: I18n.t('spree.cart')
  end

  private

  def text
    empty_current_order? ? '' : "<div class='link-text absolute flex -top-2 -right-2 items-center justify-center bg-red-500 h-5 w-5 p-0.5 rounded-full text-white text-body-sm md:text-body-2xs'>#{current_order.item_count}</div>"
  end

  def css_class
    empty_current_order? ? 'empty' : 'full'
  end

  def empty_current_order?
    current_order.nil? || current_order.item_count.zero?
  end
end
