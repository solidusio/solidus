# frozen_string_literal: true

namespace :taxes do
  desc "Creates all of the records necessary to start collecting the Colorado Delivery Fee"
  task colorado_delivery_fee: :environment do
    usa = Spree::Country.find_by!(iso: "US")
    colorado = usa.states.find_by!(abbr: "CO")

    ActiveRecord::Base.transaction do
      zone = Spree::Zone.create!(
        name: "Colorado",
        description: "State-based zone containing only Colorado.",
        states: [colorado]
      )

      calculator = Spree::Calculator::FlatFee.new
      rate = Spree::TaxRate.create!(
        name: "Colorado Delivery Fee",
        calculator: calculator,
        zone: zone,
        amount: 0.27,
        show_rate_in_label: false,
        level: "order"
      )
      rate.tax_categories << Spree::TaxCategory.default if Spree::TaxCategory.default
    end
  end
end
