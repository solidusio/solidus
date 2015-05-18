class Spree::OrderCapturing
  # Allows for prioritizing payment methods in the order to be captured
  class_attribute :sorted_payment_method_classes
  self.sorted_payment_method_classes = []

  def initialize(order, sorted_payment_method_classes = nil)
    @order = order
    @sorted_payment_method_classes = sorted_payment_method_classes || Spree::OrderCapturing.sorted_payment_method_classes
  end

  def capture_payments
    return if @order.paid?

    Spree::OrderMutex.with_lock!(@order) do
      uncaptured_amount = @order.display_total.cents

      begin
        sorted_payments(@order).each do |payment|
          amount = [uncaptured_amount, payment.money.cents].min
          break unless amount > 0

          payment.capture!(amount)
          uncaptured_amount -= amount
        end
      ensure
        @order.update!
      end
    end
  end

  private

  def sorted_payments(order)
    payments = order.pending_payments
    payments = payments.sort_by { |p| [@sorted_payment_method_classes.index(p.payment_method.class), p.id] }
  end
end
