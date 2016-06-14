module Spree
  # This class performs a data migration. It's usually run from
  # the `solidus:migrations:create_vat_prices` rake task.
  class PriceMigrator
    # Migrate all variant's prices.
    def self.migrate_default_vat_prices
      # We need to tag the exisiting prices as "default", so that the VatPriceGenerator knows
      # that they include the default zone's VAT.
      Spree::Config.admin_vat_country_iso = Spree::Zone.default_tax.countries.first.iso
      Spree::Variant.find_each do |variant|
        new(variant).migrate_vat_prices
      end
      # This line stops all weird code paths that generate refunds from happening.
      Spree::Zone.default_tax.update(default_tax: false)
    end

    attr_reader :variant

    def initialize(variant)
      @variant = variant
    end

    def migrate_vat_prices
      # With a default tax zone, all prices include VAT by default. Let's tell them which one!
      variant.prices.update_all(country_iso: Spree::Config.admin_vat_country_iso)
      Spree::Variant::VatPriceGenerator.new(variant).run
      variant.save
    end
  end
end
