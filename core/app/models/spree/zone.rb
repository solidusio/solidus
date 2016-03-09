module Spree
  class Zone < Spree::Base
    has_many :zone_members, dependent: :destroy, class_name: "Spree::ZoneMember", inverse_of: :zone
    has_many :tax_rates, dependent: :destroy, inverse_of: :zone

    with_options through: :zone_members, source: :zoneable do
      has_many :countries, source_type: "Spree::Country"
      has_many :states, source_type: "Spree::State"
    end

    has_many :shipping_method_zones
    has_many :shipping_methods, through: :shipping_method_zones

    validates :name, presence: true, uniqueness: { allow_blank: true }
    after_save :remove_defunct_members
    after_save :remove_previous_default

    scope :with_member_ids, ->(state_ids, country_ids) do
      return none if !state_ids.present? && !country_ids.present?

      spree_zone_members_table = Spree::ZoneMember.arel_table
      matching_state =
        spree_zone_members_table[:zoneable_type].eq("Spree::State").
        and(spree_zone_members_table[:zoneable_id].in(state_ids))
      matching_country =
        spree_zone_members_table[:zoneable_type].eq("Spree::Country").
        and(spree_zone_members_table[:zoneable_id].in(country_ids))
      joins(:zone_members).where(matching_state.or(matching_country)).distinct
    end

    scope :for_address, ->(address) do
      if address
        with_member_ids(address.state_id, address.country_id)
      else
        none
      end
    end

    alias :members :zone_members
    accepts_nested_attributes_for :zone_members, allow_destroy: true, reject_if: proc { |a| a['zoneable_id'].blank? }

    self.whitelisted_ransackable_attributes = ['description']

    def self.default_tax
      where(default_tax: true).first
    end

    # Returns the most specific matching zone for an address. Specific means:
    # A State zone wins over a country zone, and a zone with few members wins
    # over one with many members. If there is no match, returns nil.
    def self.match(address)
      return unless address && (matches =
                                  with_member_ids(address.state_id, address.country_id).
                                  order(:zone_members_count, :created_at, :id).
                                  references(:zones))

      ['state', 'country'].each do |zone_kind|
        if match = matches.detect { |zone| zone_kind == zone.kind }
          return match
        end
      end
      matches.first
    end

    # Returns all zones that contain any of the zone members of the zone passed
    # in. This also includes any country zones that contain the state of the
    # current zone, if it's a state zone. If the passed-in zone has members, it
    # will also be in the result set.
    def self.with_shared_members(zone)
      return none unless zone

      states_and_state_country_ids = zone.states.pluck(:id, :country_id).to_a
      state_ids = states_and_state_country_ids.map(&:first)
      state_country_ids = states_and_state_country_ids.map(&:second)
      country_ids = zone.countries.pluck(:id).to_a

      with_member_ids(state_ids, country_ids + state_country_ids).distinct
    end

    def kind
      if members.any? && !members.any? { |member| member.try(:zoneable_type).nil? }
        members.last.zoneable_type.demodulize.underscore
      end
    end

    def kind=(value)
      # do nothing - just here to satisfy the form
    end

    def include?(address)
      return false unless address

      members.any? do |zone_member|
        case zone_member.zoneable_type
        when 'Spree::Country'
          zone_member.zoneable_id == address.country_id
        when 'Spree::State'
          zone_member.zoneable_id == address.state_id
        else
          false
        end
      end
    end

    # convenience method for returning the countries contained within a zone
    def country_list
      @countries ||= case kind
                     when 'country' then zoneables
                     when 'state' then zoneables.collect(&:country)
                     else []
                     end.flatten.compact.uniq
    end

    def <=>(other)
      name <=> other.name
    end

    # All zoneables belonging to the zone members.  Will be a collection of either
    # countries or states depending on the zone type.
    def zoneables
      members.includes(:zoneable).collect(&:zoneable)
    end

    def country_ids
      if kind == 'country'
        members.pluck(:zoneable_id)
      else
        []
      end
    end

    def state_ids
      if kind == 'state'
        members.pluck(:zoneable_id)
      else
        []
      end
    end

    def country_ids=(ids)
      set_zone_members(ids, 'Spree::Country')
    end

    def state_ids=(ids)
      set_zone_members(ids, 'Spree::State')
    end

    # Indicates whether the specified zone falls entirely within the zone performing
    # the check.
    def contains?(target)
      return true if self == target
      return false if kind == 'state' && target.kind == 'country'
      return false if zone_members.empty? || target.zone_members.empty?

      if kind == target.kind
        (target.zoneables.collect(&:id) - zoneables.collect(&:id)).empty?
      else
        (target.zoneables.collect(&:country).collect(&:id) - zoneables.collect(&:id)).empty?
      end
    end

    private

    def remove_defunct_members
      if zone_members.any?
        zone_members.where('zoneable_id IS NULL OR zoneable_type != ?', "Spree::#{kind.classify}").destroy_all
      end
    end

    def remove_previous_default
      Spree::Zone.where('id != ?', id).update_all(default_tax: false) if default_tax
    end

    def set_zone_members(ids, type)
      zone_members.destroy_all
      ids.reject(&:blank?).map do |id|
        member = ZoneMember.new
        member.zoneable_type = type
        member.zoneable_id = id
        members << member
      end
    end
  end
end
