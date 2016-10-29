module Spree
  class Country < Spree::Base
    has_many :states, -> { order(:name) }, dependent: :destroy
    has_many :addresses, dependent: :nullify
    has_many :prices, class_name: "Spree::Price", foreign_key: "country_iso", primary_key: "iso"

    validates :name, :iso_name, presence: true

    # provence_label - "state" for U.S.; "Provence/Territory" for CAN
    # postal_label = "Zipcode" for U.S.; "Postal Code" almost everywhere else

    enum provence_specified: { exclude: 0, optional: 1, required: 2 }  # exclude, optional, or require the provence/state
    enum postal_postion: { right: 0, left: 1, below_city: 3, above_city: 4 } # should the postal code (zip code) appear right, left, above, or below
    enum postal_specified: { exclude: 0, optional: 1, required: 2} # should the postal code come to right, left (on city line), or above or below city line

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
