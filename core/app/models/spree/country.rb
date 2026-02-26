# frozen_string_literal: true

module Spree
  class Country < Spree::Base
    has_many :states,
      -> { order(:name) },
      dependent: :destroy,
      inverse_of: :country
    has_many :addresses,
      dependent: :restrict_with_error,
      inverse_of: :country
    has_many :prices,
      class_name: "Spree::Price",
      foreign_key: "country_iso",
      primary_key: "iso",
      dependent: :restrict_with_error,
      inverse_of: :country

    validates :name, :iso_name, :iso, presence: true
    validates :iso, uniqueness: true

    self.allowed_ransackable_attributes = %w[name]

    def self.default
      find_by!(iso: Spree::Config.default_country_iso)
    end

    def self.available(restrict_to_zone: Spree::Config[:checkout_zone])
      checkout_zone = Zone.find_by(name: restrict_to_zone)

      return checkout_zone.country_list if checkout_zone.try(:kind) == "country"

      all
    end

    def <=>(other)
      name <=> other.name
    end

    def to_s
      name
    end
  end
end
