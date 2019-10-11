# frozen_string_literal: true

module Solidus
  class StoreController < Solidus::BaseController
    include Solidus::Core::ControllerHelpers::Pricing
    include Solidus::Core::ControllerHelpers::Order

    def unauthorized
      render 'spree/shared/unauthorized', layout: Solidus::Config[:layout], status: 401
    end

    def cart_link
      render partial: 'spree/shared/link_to_cart'
      fresh_when(current_order, template: 'spree/shared/_link_to_cart')
    end

    private

    def config_locale
      Solidus::Frontend::Config[:locale]
    end

    def lock_order
      Solidus::OrderMutex.with_lock!(@order) { yield }
    rescue Solidus::OrderMutex::LockFailed
      flash[:error] = t('spree.order_mutex_error')
      redirect_to spree.cart_path
    end
  end
end
