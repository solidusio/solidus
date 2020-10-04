# frozen_string_literal: true

module Spree
  class State < Spree::Base
    belongs_to :country, class_name: 'Spree::Country', optional: true
    has_many :addresses, dependent: :nullify

    validates :country, :name, presence: true

    scope :with_name_or_abbr, ->(name_or_abbr) do
      where(
        arel_table[:name].matches(name_or_abbr).or(
          arel_table[:abbr].matches(name_or_abbr)
        )
      )
    end
    class << self
      alias_method :find_all_by_name_or_abbr, :with_name_or_abbr
      deprecate find_all_by_name_or_abbr: :with_name_or_abbr, deprecator: Spree::Deprecation
    end

    self.whitelisted_ransackable_attributes = %w[name]

    # table of { country.id => [ state.id , state.name ] }, arrays sorted by name
    # blank is added elsewhere, if needed
    def self.states_group_by_country_id
      state_info = Hash.new { |hash, key| hash[key] = [] }
      order(:name).each { |state|
        state_info[state.country_id.to_s].push [state.id, state.name]
      }
      state_info
    end

    def <=>(other)
      name <=> other.name
    end

    def to_s
      name
    end

    def state_with_country
      "#{name} (#{country})"
    end
  end
end
