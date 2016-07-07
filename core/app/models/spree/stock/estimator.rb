module Spree
  module Stock
    class Estimator
      class ShipmentRequired < StandardError; end
      class OrderRequired < StandardError; end

      # Estimate the shipping rates for a package.
      #
      # @param package [Spree::Stock::Package] the package to be shipped
      # @param frontend_only [Boolean] restricts the shipping methods to only
      #   those marked frontend if truthy
      # @return [Array<Spree::ShippingRate>] the shipping rates sorted by
      #   descending cost, with the least costly marked "selected"
      def shipping_rates(package, frontend_only = true)
        raise ShipmentRequired if package.shipment.nil?
        raise OrderRequired if package.shipment.order.nil?

        rates = calculate_shipping_rates(package)
        rates.select! { |rate| rate.shipping_method.frontend? } if frontend_only
        choose_default_shipping_rate(rates)
        Spree::Config.shipping_rate_sorter_class.new(rates).sort
      end

      private

      def choose_default_shipping_rate(shipping_rates)
        unless shipping_rates.empty?
          default_shipping_rate = Spree::Config.shipping_rate_selector_class.new(shipping_rates).find_default
          default_shipping_rate.selected = true
        end
      end

      def calculate_shipping_rates(package)
        shipping_methods(package).map do |shipping_method|
          cost = shipping_method.calculator.compute(package)
          if cost
            rate = shipping_method.shipping_rates.new(
              cost: cost,
              shipment: package.shipment
            )
            Spree::Config.shipping_rate_taxer_class.new.tax(rate)
          end
        end.compact
      end

      def shipping_methods(package)
        package.shipping_methods
          .available_for_address(package.shipment.order.ship_address)
          .includes(:calculator, tax_category: :tax_rates)
          .to_a
          .select do |ship_method|
          calculator = ship_method.calculator
          calculator.available?(package) &&
            (calculator.preferences[:currency].blank? ||
             calculator.preferences[:currency] == package.shipment.order.currency)
        end
      end
    end
  end
end
