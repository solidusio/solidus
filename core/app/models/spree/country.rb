module Spree
  class Country < Spree::Base
    has_many :states, -> { order(:name) }, dependent: :destroy
    has_many :addresses, dependent: :nullify
    has_many :prices, class_name: "Spree::Price", foreign_key: "country_iso", primary_key: "iso"

    validates :name, :iso_name, presence: true

    def self.states_required_by_country_id
      Spree::Deprecation.warn "Spree::Country.states_required_by_country_id is deprecated and will be removed from future releases, Implement it yourself.", caller
      states_required = Hash.new(true)
      all.each { |country| states_required[country.id.to_s] = country.states_required }
      states_required
    end

    def self.default
      if Spree::Config.default_country_id
        Spree::Deprecation.warn("Setting your default country via its ID is deprecated. Please set your default country via the `default_country_iso` setting.", caller)
        find_by(id: Spree::Config.default_country_id) || find_by!(iso: Spree::Config.default_country_iso)
      else
        find_by!(iso: Spree::Config.default_country_iso)
      end
    end

    def <=>(other)
      name <=> other.name
    end

    def to_s
      name
    end
  end
end
