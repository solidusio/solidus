# frozen_string_literal: true

module Spree
  class Country < Spree::Base
    has_many :states, -> { order(:name) }, dependent: :destroy
    has_many :addresses, dependent: :nullify
    has_many :prices, class_name: "Spree::Price", foreign_key: "country_iso", primary_key: "iso"

    validates :name, :iso_name, presence: true

    self.allowed_ransackable_attributes = %w[name]

    def self.default
      find_by!(iso: Spree::Config.default_country_iso)
    end

    def self.available(restrict_to_zone: Spree::Config[:checkout_zone])
      checkout_zone = Zone.find_by(name: restrict_to_zone)

      return checkout_zone.country_list if checkout_zone.try(:kind) == 'country'

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
