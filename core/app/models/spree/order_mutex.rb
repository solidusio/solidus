# frozen_string_literal: true

module Spree
  class OrderMutex < Spree::Base
    class LockFailed < StandardError; end

    belongs_to :order, class_name: "Spree::Order", optional: true

    scope :expired, -> { where(arel_table[:created_at].lteq(Spree::Config[:order_mutex_max_age].seconds.ago)) }

    class << self
      # Obtain a lock on an order, execute the supplied block and then release the lock.
      # Raise a LockFailed exception immediately if we cannot obtain the lock.
      # We raise instead of blocking to avoid tying up multiple server processes waiting for the lock.
      def with_lock!(order)
        raise ArgumentError, "order must be supplied" if order.nil?

        # limit the maximum lock time just in case a lock is somehow left in place accidentally
        expired.where(order: order).delete_all

        begin
          order_mutex = create!(order: order)
        rescue ActiveRecord::RecordNotUnique
          error = LockFailed.new("Could not obtain lock on order #{order.id}")
          logger.error error.inspect
          raise error
        end

        yield
      ensure
        order_mutex.destroy if order_mutex
      end
    end
  end
end
