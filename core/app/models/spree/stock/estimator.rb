module Spree
  module Stock
    class Estimator
      attr_reader :order, :currency

      # @param order [Spree::Order] the order whose shipping rates to estimate
      def initialize(order)
        @order = order
        @currency = order.currency
      end

      # Estimate the shipping rates for a package.
      #
      # @param package [Spree::Stock::Package] the package to be shipped
      # @param frontend_only [Boolean] restricts the shipping methods to only
      #   those marked frontend if truthy
      # @return [Array<Spree::ShippingRate>] the shipping rates sorted by
      #   descending cost, with the least costly marked "selected"
      def shipping_rates(package, frontend_only = true)
        rates = calculate_shipping_rates(package)
        rates.select! { |rate| rate.shipping_method.frontend? } if frontend_only
        choose_selected_shipping_rate(rates)
        sort_shipping_rates(rates)
      end

      private
      def choose_selected_shipping_rate(shipping_rates)
        return if shipping_rates.empty?
        shipping_rate = find_preselected_shipping_rate(shipping_rates) || shipping_rates.min_by(&:cost)
        shipping_rate.selected = true
      end

      def find_preselected_shipping_rate(shipping_rates)
        # TODO this method assumes a single shipment per order.
        # If we have multiple shipments this will assign one of the preselected
        # shipping methods to one of the shipments, which is far from ideal, but
        # no worse than the prior behavior of always resetting to cheapest.
        if order.shipments.count > 0
          shipping_method = order.shipments.map {|s| s.selected_shipping_rate.try!(:shipping_method) }.compact.uniq.first
          if shipping_method
            shipping_rates.detect {|rate| rate.shipping_method_id == shipping_method.id }
          end
        end
      end

      def sort_shipping_rates(shipping_rates)
        shipping_rates.sort_by!(&:cost)
      end

      def calculate_shipping_rates(package)
        shipping_methods(package).map do |shipping_method|
          cost = shipping_method.calculator.compute(package)
          tax_category = shipping_method.tax_category
          if tax_category
            tax_rate = tax_category.tax_rates.detect do |rate|
              # If the rate's zone matches the order's zone, a positive adjustment will be applied.
              # If the rate is from the default tax zone, then a negative adjustment will be applied.
              # See the tests in shipping_rate_spec.rb for an example of this.d
              rate.zone == order.tax_zone || rate.zone.default_tax?
            end
          end

          if cost
            rate = shipping_method.shipping_rates.new(cost: cost)
            rate.tax_rate = tax_rate if tax_rate
          end

          rate
        end.compact
      end

      def shipping_methods(package)
        package.shipping_methods.select do |ship_method|
          calculator = ship_method.calculator
          ship_method.include?(order.ship_address) &&
          calculator.available?(package) &&
          (calculator.preferences[:currency].blank? ||
           calculator.preferences[:currency] == currency)
        end
      end
    end
  end
end
