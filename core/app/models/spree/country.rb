module Spree
  class Country < Spree::Base
    has_many :states, -> { order(:name) }, dependent: :destroy
    has_many :addresses, dependent: :nullify

    validates :name, :iso_name, presence: true

    def self.states_required_by_country_id
      ActiveSupport::Deprecation.warn "Spree::Country.states_required_by_country_id is deprecated and will be removed from future releases, Implement it yourself.", caller
      states_required = Hash.new(true)
      all.each { |country| states_required[country.id.to_s]= country.states_required }
      states_required
    end

    def self.default
      find(Spree::Config[:default_country_id])
    rescue ActiveRecord::RecordNotFound
      first
    end

    def <=>(other)
      name <=> other.name
    end

    def to_s
      name
    end
  end
end
