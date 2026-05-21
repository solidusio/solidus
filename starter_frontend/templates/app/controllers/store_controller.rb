# frozen_string_literal: true

class StoreController < Spree::BaseController
  include Spree::Core::ControllerHelpers::Pricing
  include Spree::Core::ControllerHelpers::Order
  include Taxonomies

  etag { config_locale }

  layout 'storefront'

  def unauthorized
    render 'shared/auth/unauthorized', layout: Spree::Config[:layout], status: 401
  end

  def cart_link
    render partial: 'shared/cart/link_to_cart'
    fresh_when(etag: current_order, template: 'shared/cart/_link_to_cart')
  end

  private

  def config_locale
    I18n.locale
  end

  def lock_order
    Spree::OrderMutex.with_lock!(@order) { yield }
  rescue Spree::OrderMutex::LockFailed
    flash[:error] = t('spree.order_mutex_error')
    redirect_to cart_path
  end
end
