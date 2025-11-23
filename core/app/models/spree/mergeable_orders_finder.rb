# frozen_string_literal: true

module Spree
  # Finds orders to merge when a user logs in.
  #
  # Configurable via {Spree::Config#mergeable_orders_finder_class}.
  # Default behavior finds all incomplete orders from the same store.
  #
  # @example Custom finder for recent orders only
  #   class RecentOrdersFinder
  #     def initialize(context:)
  #       @user = context.spree_current_user
  #       @store = context.current_store
  #       @current_order = context.current_order
  #     end
  #
  #     def call
  #       @user.orders.by_store(@store).incomplete
  #            .where.not(id: @current_order.id)
  #            .where('created_at > ?', 7.days.ago)
  #     end
  #   end
  #
  #   Spree::Config.mergeable_orders_finder_class = RecentOrdersFinder
  class MergeableOrdersFinder
    # @param context [Object] an object that responds to spree_current_user,
    #   current_store, and current_order (typically a controller)
    def initialize(context:)
      @user = context.spree_current_user
      @store = context.current_store
      @current_order = context.current_order
    end

    # Returns orders that should be merged into the current order
    #
    # @return [ActiveRecord::Relation<Spree::Order>] incomplete orders from the
    # same store
    def call
      return Spree::Order.none unless @user && @current_order

      @user.orders.by_store(@store).incomplete.where(frontend_viewable: true).where.not(id: @current_order.id)
    end
  end
end
