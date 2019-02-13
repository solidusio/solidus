module Spree
  class Order
    module Interactors
      class Finalizer
        include EventedInteractor

        delegate :all_adjustments, :updater, :shipments, :save!, :touch,
          :deliver_order_confirmation_email, :confirmation_delivered?, to: :order

        def call
          Spree::Event.instrument 'order_finalize', order: order do
            # lock all adjustments (coupon promotions, etc.)
            all_adjustments.each(&:finalize!)

            # update payment and shipment(s) states, and save
            updater.update_payment_state
            shipments.each do |shipment|
              shipment.update_state
              shipment.finalize!
            end

            updater.update_shipment_state
            save!
            updater.run_hooks

            touch :completed_at
          end
        end

        private

        def order
          context.order
        end
      end
    end
  end
end
