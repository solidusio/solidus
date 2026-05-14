module Spree
  module Stock
    module Middleware
      class Shipment
        def call(context)
          context[:shipments] = context[:packages].map do |package|
            shipment = package.shipment = package.to_shipment
            shipment.shipping_rates = Spree::Config.stock.estimator_class.new.shipping_rates(package)
            shipment
          end
        end
      end
    end
  end
end
