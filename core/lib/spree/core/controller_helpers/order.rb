# frozen_string_literal: true

require 'spree/core/controller_helpers/pricing'

module Spree
  module Core
    module ControllerHelpers
      module Order
        extend ActiveSupport::Concern
        include ControllerHelpers::Pricing

        included do
          helper_method :current_order
          helper_method :simple_current_order
        end

        def simple_current_order
          return @simple_current_order if @simple_current_order

          @simple_current_order = find_order_by_token_or_user

          if @simple_current_order
            @simple_current_order.last_ip_address = ip_address
            return @simple_current_order
          else
            @simple_current_order = Spree::Order.new(current_order_params)
          end
        end
        deprecate simple_current_order: :current_order, deprecator: Spree::Deprecation

        # The current incomplete order from the guest_token for use in cart and during checkout
        def current_order(options = {})
          should_create = options[:create_order_if_necessary] || false
          should_build = options[:build_order_if_necessary] || should_create

          return @current_order if @current_order

          @current_order = find_order_by_token_or_user(lock: options[:lock])

          if should_build && (@current_order.nil? || @current_order.completed?)
            @current_order = Spree::Order.new(new_order_params)
            @current_order.user ||= try_spree_current_user
            # See issue https://github.com/spree/spree/issues/3346 for reasons why this line is here
            @current_order.created_by ||= try_spree_current_user
            @current_order.save! if should_create
          end

          if @current_order
            @current_order.record_ip_address(ip_address)
            return @current_order
          end
        end

        def associate_user
          @order ||= current_order
          if try_spree_current_user && @order
            @order.associate_user!(try_spree_current_user) if @order.user.blank? || @order.email.blank?
          end
        end

        def set_current_order
          if try_spree_current_user && current_order
            try_spree_current_user.orders.by_store(current_store).incomplete.where('id != ?', current_order.id).each do |order|
              current_order.merge!(order, try_spree_current_user)
            end
          end
        end

        def ip_address
          request.remote_ip
        end

        private

        def last_incomplete_order
          @last_incomplete_order ||= try_spree_current_user.last_incomplete_spree_order(store: current_store)
        end

        def current_order_params
          { currency: current_pricing_options.currency, guest_token: cookies.signed[:guest_token], store_id: current_store.id, user_id: try_spree_current_user.try(:id) }
        end

        def new_order_params
          current_order_params.merge(last_ip_address: ip_address)
        end

        def find_order_by_token_or_user(options = {}, with_adjustments = false)
          should_lock = options[:lock] || false

          # Find any incomplete orders for the guest_token
          if with_adjustments
            Spree::Deprecation.warn "The second argument to find_order_by_token_or_user is deprecated, and will be removed in a future version."
            order = Spree::Order.incomplete.includes(:adjustments).lock(should_lock).find_by(current_order_params)
          else
            order = Spree::Order.incomplete.lock(should_lock).find_by(current_order_params)
          end

          # Find any incomplete orders for the current user
          if order.nil? && try_spree_current_user
            order = last_incomplete_order
          end

          order
        end
      end
    end
  end
end
