# frozen_string_literal: true

module Solidus
  class Asset < Solidus::Base
    belongs_to :viewable, polymorphic: true, touch: true, optional: true
    acts_as_list scope: [:viewable_id, :viewable_type]
  end
end
