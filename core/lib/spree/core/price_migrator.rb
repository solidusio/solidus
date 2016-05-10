module Spree
  class PriceMigrator
    def self.migrate_default_vat_prices
      Spree::Config.admin_vat_country_iso = Spree::Zone.default_tax.countries.first.iso
      Spree::Config.remove_instance_variable(:@default_pricing_options)
      Spree::Variant.find_each do |variant|
        new(variant).migrate_vat_prices
      end
      Spree::Zone.default_tax.update(default_tax: false)
    end

    attr_reader :variant

    def initialize(variant)
      @variant = variant
    end

    def migrate_vat_prices
      variant.prices.update_all(country_iso: Spree::Config.admin_vat_country_iso)
      Spree::Variant::PriceGenerator.new(variant).run
      variant.save
    end
  end
end
