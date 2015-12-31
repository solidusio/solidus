module Solidus
  class ZoneMember < Solidus::Base
    belongs_to :zone, class_name: 'Solidus::Zone', counter_cache: true, inverse_of: :zone_members
    belongs_to :zoneable, polymorphic: true

    def name
      return nil if zoneable.nil?
      zoneable.name
    end
  end
end
