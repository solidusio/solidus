# frozen_string_literal: true

module Solidus
  class ZoneMember < Solidus::Base
    belongs_to :zone, class_name: 'Solidus::Zone', counter_cache: true, inverse_of: :zone_members, optional: true
    belongs_to :zoneable, polymorphic: true, optional: true

    delegate :name, to: :zoneable, allow_nil: true
  end
end
